"""
Export results in multiple formats: JSON, CSV, Excel, PDF
"""

import json
import csv
import io
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional

try:
    from openpyxl import Workbook
    from openpyxl.styles import Font, PatternFill, Alignment
    HAS_OPENPYXL = True
except ImportError:
    HAS_OPENPYXL = False

try:
    from reportlab.lib.pagesizes import letter
    from reportlab.lib.units import inch
    from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.lib import colors
    HAS_REPORTLAB = False  # We'll implement simple PDF later
except ImportError:
    HAS_REPORTLAB = False


class ResultExporter:
    """Export classification results in various formats"""
    
    def __init__(self, results: List[Dict], labels: List[str], filenames: List[str]):
        """
        Initialize exporter
        
        Args:
            results: Classification results from CLIPClassifier.classify()
            labels: Original labels used for classification
            filenames: Original image filenames
        """
        self.results = results
        self.labels = labels
        self.filenames = filenames
        self.timestamp = datetime.now().isoformat()
        
        # Combine with filenames
        self.enriched_results = self._enrich_results()
    
    def _enrich_results(self) -> List[Dict]:
        """Combine results with filenames"""
        enriched = []
        for i, result in enumerate(self.results):
            enriched.append({
                "filename": self.filenames[i] if i < len(self.filenames) else f"image_{i}",
                **result
            })
        return enriched
    
    def to_json(self, indent: int = 2) -> str:
        """
        Export as JSON
        
        Args:
            indent: JSON indentation level
            
        Returns:
            JSON string
        """
        payload = {
            "metadata": {
                "timestamp": self.timestamp,
                "total_images": len(self.results),
                "labels": self.labels,
            },
            "results": self.enriched_results,
            "summary": self._create_summary(),
        }
        return json.dumps(payload, indent=indent)
    
    def to_csv(self) -> str:
        """
        Export as CSV (spreadsheet friendly)
        
        Returns:
            CSV string
        """
        if not self.enriched_results:
            return ""
        
        output = io.StringIO()
        
        # Get all unique labels for columns
        all_scores = {}
        for result in self.enriched_results:
            for score_item in result.get("scores", []):
                label = score_item["label"]
                if label not in all_scores:
                    all_scores[label] = None
        
        fieldnames = ["filename", "top_label", "confidence_%"] + sorted(all_scores.keys())
        writer = csv.DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()
        
        for result in self.enriched_results:
            row = {
                "filename": result["filename"],
                "top_label": result["top_label"],
                "confidence_%": result["top_score"],
            }
            
            # Add all label scores
            score_dict = {item["label"]: item["score"] for item in result.get("scores", [])}
            for label in all_scores:
                row[label] = score_dict.get(label, 0)
            
            writer.writerow(row)
        
        return output.getvalue()
    
    def to_excel(self, filename: str = "results.xlsx") -> Optional[bytes]:
        """
        Export as Excel (.xlsx) with formatting
        
        Args:
            filename: Output filename
            
        Returns:
            Excel file bytes or None if openpyxl not installed
        """
        if not HAS_OPENPYXL:
            raise ImportError(
                "openpyxl required for Excel export. "
                "Install with: pip install openpyxl"
            )
        
        wb = Workbook()
        
        # Summary sheet
        ws_summary = wb.active
        ws_summary.title = "Summary"
        
        summary = self._create_summary()
        ws_summary["A1"] = "Classification Summary"
        ws_summary["A1"].font = Font(bold=True, size=14)
        
        row = 3
        for label, files in summary.items():
            ws_summary[f"A{row}"] = label
            ws_summary[f"B{row}"] = len(files)
            row += 1
        
        ws_summary.column_dimensions["A"].width = 20
        ws_summary.column_dimensions["B"].width = 10
        
        # Details sheet
        ws_details = wb.create_sheet("Details")
        
        # Get all unique labels
        all_labels = set()
        for result in self.enriched_results:
            for score_item in result.get("scores", []):
                all_labels.add(score_item["label"])
        all_labels = sorted(list(all_labels))
        
        # Header row
        headers = ["Filename", "Top Label", "Confidence %"] + all_labels
        ws_details.append(headers)
        
        # Format header
        header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
        header_font = Font(bold=True, color="FFFFFF")
        
        for col_num, header in enumerate(headers, 1):
            cell = ws_details.cell(row=1, column=col_num)
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal="center")
        
        # Data rows
        for result in self.enriched_results:
            score_dict = {item["label"]: item["score"] for item in result.get("scores", [])}
            
            row_data = [
                result["filename"],
                result["top_label"],
                result["top_score"],
            ]
            
            for label in all_labels:
                row_data.append(score_dict.get(label, 0))
            
            ws_details.append(row_data)
        
        # Set column widths
        ws_details.column_dimensions["A"].width = 25
        ws_details.column_dimensions["B"].width = 15
        ws_details.column_dimensions["C"].width = 12
        for label in all_labels:
            ws_details.column_dimensions[label].width = 12
        
        # Save to bytes
        output = io.BytesIO()
        wb.save(output)
        output.seek(0)
        return output.getvalue()
    
    def to_pdf(self, filename: str = "results.pdf") -> Optional[bytes]:
        """
        Export as PDF (simple text-based report)
        
        For now, returns a simple PDF with text data.
        Install reportlab for full implementation.
        
        Args:
            filename: Output filename
            
        Returns:
            PDF file bytes or None if reportlab not installed
        """
        try:
            from reportlab.pdfgen import canvas
            from reportlab.lib.pagesizes import letter
        except ImportError:
            raise ImportError(
                "reportlab required for PDF export. "
                "Install with: pip install reportlab"
            )
        
        output = io.BytesIO()
        c = canvas.Canvas(output, pagesize=letter)
        
        width, height = letter
        y = height - 40
        
        # Title
        c.setFont("Helvetica-Bold", 16)
        c.drawString(40, y, "CLIP Image Classification Report")
        y -= 30
        
        # Metadata
        c.setFont("Helvetica", 10)
        c.drawString(40, y, f"Generated: {self.timestamp}")
        y -= 15
        c.drawString(40, y, f"Total Images: {len(self.results)}")
        y -= 25
        
        # Summary section
        c.setFont("Helvetica-Bold", 12)
        c.drawString(40, y, "Summary by Category:")
        y -= 20
        
        c.setFont("Helvetica", 10)
        summary = self._create_summary()
        for label, files in sorted(summary.items()):
            c.drawString(50, y, f"• {label}: {len(files)} images")
            y -= 15
            if y < 100:  # New page
                c.showPage()
                y = height - 40
        
        y -= 20
        
        # Details section
        c.setFont("Helvetica-Bold", 12)
        c.drawString(40, y, "Detailed Results:")
        y -= 20
        
        c.setFont("Helvetica", 9)
        for result in self.enriched_results:
            if y < 80:  # New page
                c.showPage()
                y = height - 40
            
            c.drawString(50, y, f"{result['filename']}")
            y -= 12
            c.drawString(60, y, f"Top: {result['top_label']} ({result['top_score']}%)")
            y -= 15
        
        c.save()
        output.seek(0)
        return output.getvalue()
    
    def _create_summary(self) -> Dict[str, List[str]]:
        """Create grouped summary by label"""
        summary = {}
        for result in self.enriched_results:
            label = result["top_label"]
            if label not in summary:
                summary[label] = []
            summary[label].append(result["filename"])
        return summary
    
    def save(self, format: str, output_path: str) -> str:
        """
        Save results to file
        
        Args:
            format: Export format (json, csv, excel, pdf)
            output_path: Path to save file
            
        Returns:
            Path where file was saved
        """
        format = format.lower()
        output_path = Path(output_path)
        
        if format == "json":
            output_path.write_text(self.to_json())
        
        elif format == "csv":
            output_path.write_text(self.to_csv())
        
        elif format == "excel":
            data = self.to_excel()
            if data:
                output_path.write_bytes(data)
        
        elif format == "pdf":
            data = self.to_pdf()
            if data:
                output_path.write_bytes(data)
        
        else:
            raise ValueError(f"Unknown format: {format}")
        
        return str(output_path)

"""
Configuration management for CLIP classifier
Handles dev vs production settings
"""

import json
import os
from pathlib import Path
from typing import Optional

class Config:
    """Load and manage application configuration"""
    
    def __init__(self, env: Optional[str] = None):
        """
        Initialize config
        
        Args:
            env: Environment name ('dev' or 'production'). 
                 Defaults to CLIP_ENV env var or 'dev'
        """
        if env is None:
            env = os.getenv('CLIP_ENV', 'dev')
        
        self.env = env
        self._config = self._load_config()
        self._settings = self._config.get(self.env, self._config.get('dev'))
    
    def _load_config(self) -> dict:
        """Load config from JSON file"""
        config_path = Path(__file__).parent.parent / 'config.json'
        
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        
        with open(config_path, 'r') as f:
            return json.load(f)
    
    @property
    def model_name(self) -> str:
        """Get selected CLIP model"""
        return self._settings['model']
    
    @property
    def batch_size(self) -> int:
        """Get batch size for processing"""
        return self._settings['batch_size']
    
    @property
    def device(self) -> str:
        """Get device (cpu or cuda)"""
        return self._settings['device']
    
    @property
    def max_images(self) -> int:
        """Get max images allowed per request"""
        return self._settings['max_images']
    
    @property
    def default_labels(self) -> list:
        """Get default classification labels"""
        return self._config.get('default_labels', [])
    
    @property
    def supported_formats(self) -> list:
        """Get list of supported image formats"""
        return list(self._config['image_formats'].keys())
    
    @property
    def export_formats(self) -> list:
        """Get list of supported export formats"""
        return self._config['export_formats']
    
    @property
    def env_name(self) -> str:
        """Get environment description"""
        return self._settings['name']
    
    def __repr__(self) -> str:
        return (
            f"Config(env={self.env}, "
            f"model={self.model_name}, "
            f"device={self.device})"
        )


# Global config instance
_config = None

def get_config(env: Optional[str] = None) -> Config:
    """Get or create config instance"""
    global _config
    if _config is None:
        _config = Config(env)
    return _config

def set_config(env: str) -> Config:
    """Set environment and reload config"""
    global _config
    _config = Config(env)
    return _config

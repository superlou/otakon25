from datetime import datetime


class Timer:
    def __init__(self, description):
        self.description = description
    
    def __enter__(self):
        self.start = datetime.now()
    
    def __exit__(self, *args):
        delta = datetime.now() - self.start
        print(self.description + ": " + str(delta))
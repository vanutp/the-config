class _AppEvalError(Exception):
    def __init__(self, stdout: str, stderr: str):
        super().__init__('Failed to evaluate app config: {stderr}')
        self.stdout = stdout
        self.stderr = stderr


class DockerComposeError(Exception):
    def __init__(self, command: str, stdout: str, stderr: str):
        super().__init__(f'Failed to run docker compose command "{command}": {stderr}')
        self.command = command
        self.stdout = stdout
        self.stderr = stderr

class LoginError(DockerComposeError): ...

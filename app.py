"""
Simple Flask web app demonstrating usage of vulnerable dependencies.
This is for Dependabot demo purposes only - DO NOT deploy to production!
"""

from flask import Flask, render_template_string, request, jsonify
import requests
import yaml
from jinja2 import Environment, BaseLoader

app = Flask(__name__)


@app.route("/")
def index():
    return render_template_string("""
    <html>
    <head><title>Dependabot Demo App</title></head>
    <body>
        <h1>Dependabot SCA Demo</h1>
        <p>This app intentionally uses vulnerable dependencies.</p>
        <ul>
            <li><a href="/fetch?url=https://httpbin.org/get">/fetch</a> - Fetch a URL (uses requests)</li>
            <li><a href="/parse-yaml">/parse-yaml</a> - Parse YAML (uses PyYAML)</li>
            <li><a href="/render">/render</a> - Render template (uses Jinja2)</li>
            <li><a href="/health">/health</a> - Health check</li>
        </ul>
    </body>
    </html>
    """)


@app.route("/fetch")
def fetch_url():
    """Fetch a URL using the requests library."""
    url = request.args.get("url", "https://httpbin.org/get")
    try:
        response = requests.get(url, timeout=5)
        return jsonify({
            "status_code": response.status_code,
            "content_length": len(response.content),
        })
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500


@app.route("/parse-yaml", methods=["GET", "POST"])
def parse_yaml():
    """Parse YAML content using PyYAML."""
    if request.method == "POST":
        content = request.form.get("yaml_content", "")
        try:
            data = yaml.safe_load(content)
            return jsonify({"parsed": data})
        except yaml.YAMLError as e:
            return jsonify({"error": str(e)}), 400

    return render_template_string("""
    <html>
    <body>
        <h2>YAML Parser</h2>
        <form method="POST">
            <textarea name="yaml_content" rows="10" cols="50">name: demo
version: 1.0</textarea>
            <br>
            <button type="submit">Parse</button>
        </form>
    </body>
    </html>
    """)


@app.route("/render")
def render_template():
    """Render a Jinja2 template."""
    name = request.args.get("name", "World")
    env = Environment(loader=BaseLoader())
    template = env.from_string("Hello, {{ name }}!")
    return template.render(name=name)


@app.route("/health")
def health():
    """Health check endpoint."""
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)

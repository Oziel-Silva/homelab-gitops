from flask import Flask, request
# from opentelemetry.instrumentation.flask import FlaskInstrumentor
# from opentelemetry import trace
# from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
# from opentelemetry.sdk.trace.export import BatchSpanProcessor
# from opentelemetry.sdk.trace import TracerProvider

app = Flask(__name__)

# Setup tracer
# provider = TracerProvider()
# provider.add_span_processor(
#     BatchSpanProcessor(
#         OTLPSpanExporter(endpoint="http://tempo-distributor.monitoring.svc.cluster.local:4317")
#     )
# )
# trace.set_tracer_provider(provider)
# FlaskInstrumentor().instrument_app(app)

@app.route("/")
def hello():
    # perf_id = request.headers.get("x-perf-test-id")
    # span = trace.get_current_span()
    # if perf_id:
    #     span.set_attribute("perf.test.id", perf_id)
    #     print("TRACE ID:", trace.get_current_span().get_span_context().trace_id)

    return "Traced hello!"

@app.route("/server_request")
def server_request():
    print(request.args.get("param"))
    return "served"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

# from flask import Flask, request

# app = Flask(__name__)

# @app.route("/")
# def hello():

#     print("HEADERS RECEBIDOS:")
#     for header, value in request.headers.items():
#         print(f"{header}: {value}")

 
#     perf_id = request.headers.get("x-perf-test-id")
#     if perf_id:
#         print("x-perf-test-id:", perf_id)

#     return "Traced hello!"

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=8000)
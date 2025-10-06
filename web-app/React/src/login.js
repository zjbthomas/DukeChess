async function sha256_text(text) {
  const enc = new TextEncoder().encode(text);
  const buf = await crypto.subtle.digest("SHA-256", enc);
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
}
window.sha256_text = sha256_text;

function Login(props) {
  const [username, setUsername] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [error, setError]       = React.useState("");
  const [busy, setBusy]         = React.useState(false);

  const IS_DEBUG = false;
  const API_URL = (IS_DEBUG ? "http://127.0.0.1" : "https://175.178.11.87") + "/api/login";

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setBusy(true);
    try {
      const password_hash = await window.sha256_text(password);
      const res = await fetch(API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: username, password: password_hash }) 
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(data.error || "Login failed");
        return;
      }
      if (data.status === "ok" || data.status === "registered") {
        // Pass creds to dukechess.js
        props.onLogin && props.onLogin(username, password_hash);
      } else {
        setError("Unexpected response");
      }
    } catch (err) {
      setError("Network error");
    } finally {
      setBusy(false);
    }
  }

  return React.createElement(
    "div",
    { className: "login-container", style: { textAlign: "center", marginTop: "80px" } },
    React.createElement(
      "form",
      { onSubmit: handleSubmit, style: { display: "inline-block", textAlign: "left" } },
      React.createElement(
        "div",
        null,
        React.createElement("label", null, "Username"), React.createElement("br"),
        React.createElement("input", {
          type: "text",
          value: username,
          onChange: e => setUsername(e.target.value),
          required: true
        })
      ),
      React.createElement(
        "div",
        { style: { marginTop: "10px" } },
        React.createElement("label", null, "Password"), React.createElement("br"),
        React.createElement("input", {
          type: "password",
          value: password,
          onChange: e => setPassword(e.target.value),
          required: true
        })
      ),
      error ? React.createElement("div", { style: { color: "red", marginTop: "10px" } }, error) : null,
      React.createElement(
        "button",
        { type: "submit", style: { marginTop: "20px", width: "100%" }, disabled: busy },
        busy ? "Logging in…" : "Login"
      )
    )
  );
}
window.Login = Login;
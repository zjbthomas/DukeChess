extends Node

class_name User

enum LOGIN_STATUS {SERVER_ERROR, NEW_LOGIN, WRONG_PASSWORD, SUCCESSFUL_LOGIN}

var username = ""
var password = ""

# functions for connecting to Redis
const _IS_DEBUG = false
var API_BASE = ("http://127.0.0.1" if _IS_DEBUG else "https://175.178.11.87")

func _post(url, body):
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(body)
	var err = Global.http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK: return {"error":"request_failed"}
	var res = await Global.http.request_completed
	return _parse_http_result(res)

func _get(url):
	var err = Global.http.request(url, [], HTTPClient.METHOD_GET) 
	if err != OK: return {"error":"request_failed"}
	var res = await Global.http.request_completed
	return _parse_http_result(res)

func _parse_http_result(res):
	var code = res[1]
	var body = res[3]
	var text = body.get_string_from_utf8()
	if code >= 200 and code < 300:
		var parsed = JSON.parse_string(text)
		return parsed if parsed != null else {}
	return {"error": "http_%d" % code, "body": text}

func login(username, password_attempt):
	self.username = username
	self.password = password_attempt.sha256_text()

	var payload = {
		"username": username,
		"password": password
	}
	var res = await _post("%s/api/login" % API_BASE, payload)

	if res is Dictionary and res.has("error"):
		if (res.error == 'request_failed'):
			return LOGIN_STATUS.SERVER_ERROR
		return LOGIN_STATUS.WRONG_PASSWORD

	if res.status == "registered":
		return LOGIN_STATUS.NEW_LOGIN
	elif res.status == "ok":
		return LOGIN_STATUS.SUCCESSFUL_LOGIN

	return LOGIN_STATUS.SERVER_ERROR

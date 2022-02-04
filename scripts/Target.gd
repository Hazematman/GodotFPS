extends StaticBody


remotesync func destroy():
	queue_free()

func hit():
	rpc("destroy")

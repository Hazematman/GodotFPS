tool
extends Spatial

export var playIK = false setget do_playIK



func do_playIK(play):
	playIK = play
	if playIK:
		$Root/Skeleton/BackIK.start()
		$Root/Skeleton/LeftHandIK.start()
		$Root/Skeleton/RightHandIK.start()
	else:
		$Root/Skeleton/BackIK.stop()
		$Root/Skeleton/LeftHandIK.stop()
		$Root/Skeleton/RightHandIK.stop()
		

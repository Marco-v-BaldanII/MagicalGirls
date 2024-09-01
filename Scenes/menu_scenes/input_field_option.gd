extends Option
class_name InputFieldOption

func execute_option() -> bool:
	grab_focus() #programatically edit a textEdit without having to click on it
	return true

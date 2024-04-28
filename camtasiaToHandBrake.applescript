-- Choose camtasia project and set file, folder path, and project name
set f to choose file with prompt "Please select a camtasia project:" of type {"cmproj"} -- File as alias Users:derek:Desktop:example.txt
tell application "Finder" to set dir to (container of f) as text -- Text of alias for parent folder Users:derek:Desktop:
set dirPath to POSIX path of dir -- Posix path /Users/derek/Desktop
tell application "Finder" to set camtasiaName to name of f -- Get proj name i.e Demo.cmproj

-- Function to replace x in input with y
on replace(input, x, y) 
    set text item delimiters to x
    set ti to text items of input
    set text item delimiters to y
    ti as text
end replace

-- Process current date and time into time stamp to create a unique file name
set now to current date
set timeStamp to ((year of now) & ((month of now) as number) & (day of now) & (time of now)) as text
set videoName to replace(camtasiaName,".cmproj","") & " " & timeStamp -- Unique file name

-- Open camtasia project with camtasia as long as camtasia is the default app to open .cmproj files 
tell application "Finder" -- Open file
     open file f
     delay 1
end tell

-- Bounce video to camtasia directory with unique file name
tell application "System Events" to tell process "Camtasia" -- Bounce file out of camtasia
    keystroke "e" using {command down}
    delay 1
    keystroke videoName 
    delay 1
    keystroke "g" using {command down, shift down} -- open go to dialog
    delay 1
    keystroke dirPath -- path of file
    delay 1
    keystroke return -- close go to dialog with enter key
    delay 1
    keystroke return -- initiate bounce
end tell

-- Give camtasia some time to create temp file
delay 5

-- Prepare while loop
set sb to true
set tempFile to (videoName & ".mp4.sb-b") as text

-- Loop and wait until tempfile is no longer in folder
repeat while sb
    set stillSB to false
    set folderContents to list folder dir
    repeat with folderFile in folderContents
        if folderFile contains tempFile then 
            set stillSB to true
            delay 2
            exit repeat
        end if
    end repeat
    set sb to stillSB
end repeat

-- Set destination and source paths 
set sourcePath to POSIX path of (dir & videoName & ".mp4")
set destPath to POSIX path of (dir & videoName & " comp.mp4")

try
    -- Run handbrake on bounced video
    delay 1
    do shell script "HandBrakeCLI -i " & "'" & sourcePath & "'" & " -o " & "'" & destPath & "'"

    -- Notify user video is ready
    delay 1
    tell application "Finder"
        activate
        open folder dir
    end tell
    display dialog "Your video has been bounced and compressed and is now available: " & videoName & " comp.mp4"

on error errorMessage
    display dialog "Error running Handbrake. Please install the HandBrakeCLI. " & errorMessage
end try



-- NOTES
-------------------------------------------
-- user could mess up file while in progress 
-- user needs handbrake cli installed. Can maybe create something that installs it for them.


Function ShowVideoScreen(title as String, video_array as object) as integer
    this = {
        videoScreen: CreateObject("roPosterScreen")
        videoScreenPort: CreateObject("roMessagePort")
        videos: video_array
    }
    this.videoScreen.SetMessagePort(this.videoScreenPort)
    this.videoScreen.SetBreadcrumbText(title, "")
    this.videoScreen.SetContentList(this.videos)
    this.videoScreen.Show()
    
    while(true)
        msg = wait(0,this.videoScreenPort)
        if (type(msg) = "roPosterScreenEvent")
            if (msg.IsListItemSelected())
                PlayVideo(this.videos[msg.GetIndex()])
            else if (msg.isScreenClosed()) then
                return -1
            end if
        end if
    end while

End Function

Function PlayVideo(video as object) as integer
    videoScreen = CreateObject("roVideoScreen")
    port = CreateObject("roMessagePort")
    videoScreen.SetMessagePort( port )

    metaData = {
        ContentType: "episode",
        Title: video.Title,
        Description: video.Title,
        Stream: {
            Url: video.Url
        }
        StreamFormat: "hls"
    }
    videoScreen.SetContent( metaData )
    videoScreen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roVideoScreenEvent"
            if (msg.isScreenClosed())
                return -1
            end if
        endif
    end while
    
    
End Function
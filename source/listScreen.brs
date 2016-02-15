Function showListScreen() as integer
    this = {
        listScreen: CreateObject("roListScreen")
        listScreenPort: CreateObject("roMessagePort")
        topics: get_playlist_static()
        FormatBreadcrumb: format_breadcrumb
        topic_count: 0
    }
    this.listScreen.SetMessagePort(this.listScreenPort)
    this.listScreen.SetTitle("Web Services Sample Channel")
    this.listScreen.SetHeader("Topics")
    this.topic_count = Stri(this.topics.Count())
    this.listScreen.SetBreadcrumbText(Stri(this.topics.Count()), "")
    this.listScreen.SetContent(this.topics)
    this.listScreen.Show()
    while (true)
        msg = wait(1000, this.listScreenPort)
        if (type(msg) = "roListScreenEvent")
            if (msg.isListItemSelected())
                index = msg.GetIndex()
                showSpringboardScreen(this.topics[index])
            else if (msg.isListItemFocused())
                this.listScreen.SetBreadcrumbText(this.FormatBreadcrumb(msg.GetIndex()), "")                
            endif
        endif
        if (msg = invalid)
            print "No message received, do some other work before checking for events again"
        endif
    end while
    return 1
End Function

Function format_breadcrumb(id as integer) as String
    return "Topic " + Stri(id) + " of " + m.topic_count
End Function

Function get_playlist_static() as object 
    port = CreateObject("roMessagePort")
    playlistJson = [{   ContentType:"episode"
               SDPosterUrl:"file://pkg:/images/DanGilbert.jpg"
               HDPosterUrl:"file://pkg:/images/DanGilbert.jpg"
               IsHD:False
               HDBranded:False
               ShortDescriptionLine1:"Dan Gilbert asks, Why are we happy?"
               ShortDescriptionLine2:""
               Description:"Harvard psychologist Dan Gilbert says our beliefs about what will make us happy are often wrong -- a premise he supports with intriguing research, and explains in his accessible and unexpectedly funny book, Stumbling on Happiness."
               Rating:"NR"
               StarRating:"80"
               Length:1280
               Categories:["Technology","Talk"]
               Title:"Dan Gilbert asks, Why are we happy?"
               },
               { ContentType:"episode"
               SDPosterUrl:"file://pkg:/images/CraigVenter-2008.jpg"
               HDPosterUrl:"file://pkg:/images/CraigVenter-2008.jpg"
               IsHD:False
               HDBranded:False
               ShortDescriptionLine1:"Can we create new life out of our digital universe?"
               ShortDescriptionLine2:""
               Description:"He walks the TED2008 audience through his latest research into fourth-generation fuels -- biologically created fuels with CO2 as their feedstock. His talk covers the details of creating brand-new chromosomes using digital technology, the reasons why we would want to do this, and the bioethics of synthetic life. A fascinating Q&A with TED's Chris Anderson follows."
               Rating:"NR"
               StarRating:"80"
               Length:1972
               Categories:["Technology","Talk"]
               Title:"Craig Venter asks, Can we create new life out of our digital universe?"
               },
               {   ContentType:"episode"
               SDPosterUrl:"file://pkg:/images/BigBuckBunny.jpg"
               HDPosterUrl:"file://pkg:/images/BigBuckBunny.jpg"
               IsHD:true
               HDBranded:true
               ShortDescriptionLine1:"Big Buck Bunny"
               ShortDescriptionLine2:""
               Description:"Big Buck Bunny is being served using a Wowza server running on Amazon EC2 cloud services. The video is transported via HLS HTTP Live Streaming. A team of small artists from the Blender community produced this open source content..."
               Rating:"NR"
               StarRating:"80"
               Length:600
               Categories:["Technology","Cartoon"]
               Title:"Big Buck Bunny"
            }]
            
    playlist = CreateObject("roArray", 10, true)
                   
                    for each kind in playlistJson
                        topic = {
                            ID: kind.id
                            Title: kind.Title
                        }
                        playlist.push(topic)
                    end for
                    return playlist
End Function

Function get_playlist() as object
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.SetUrl("http://www.khanacademy.org/api/v1/playlists")
    
    if (request.AsyncGetToString())
        while (true)
            msg = wait(0, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                if (code = 200)
                    playlist = CreateObject("roArray", 10, true)
                    json = ParseJSON(msg.GetString())
                    for each kind in json
                        topic = {
                            ID: kind.id
                            Title: kind.standalone_title
                        }
                        playlist.push(topic)
                    end for
                    return playlist
                endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif
    return invalid
End Function

Function get_topic_videos(videoUrl as String) as object
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.SetUrl(videoUrl)
    
    if (request.AsyncGetToString())
        while (true)
            msg = wait(1000, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                if (code = 200)
                    videos = CreateObject("roArray", 10, true)
                    json = ParseJSON(msg.GetString())
                    for each kind in json
                        video = {
                            Title: kind.title
                            ShortDescriptionLine1: kind.description
                            Description: kind.description
                            Views: kind.views
                        }
                        if (kind.download_urls <> invalid)
                            video.SDPosterURL = kind.download_urls.png
                            video.HDPosterURL = kind.download_urls.png
                            video.Url = kind.download_urls.m3u8
                        endif
                        
                        videos.push(video)
                    end for
                    return videos
                endif
            endif
            if (msg = invalid)
                request.AsyncCancel()
            endif            
        end while
    endif
    return invalid
End Function


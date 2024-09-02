class NewsItem {
    constructor(postData) {
        this.id = postData.id;
        this.publishDate = postData.created_time;
        this.content = postData.message;
    }

    /**
     * 
     * @param {Object} data 
     * @param {Facebook} facebookClient 
     * @param {Function} completion Parameters: (error: Object, result: Object)
     */
    attachAttachments(data, facebookClient, completion) {
        var item = this;
        //console.log(data[0].type);
        if (data[0].type == 'album') {
            var dataPhotos = data[0].subattachments.data;
            var photos = [];
            dataPhotos.forEach(dataPhoto => {
                var photo = {
                    description: dataPhoto.description,
                    media: dataPhoto.media.image
                };
                photos.push(photo);
            });
            item.photos = photos;
            completion(null, item);

        } else if (data[0].type == 'photo') {
            item.photos = [
                {
                    description: data[0].description,
                    media: data[0].media.image
                }
            ];
            completion(null, item);

        } else if (data[0].type == 'event') {
            facebookClient.api('/' + data[0].target.id, function(err, response) {
                if (err) { completion(err, null); return; }
                item.event = {
                    name: response.name,
                    description: response.description,
                    start: response.start_time,
                    end: response.end_time,
                    location: {
                        name: response.place.name,
                        latitude: response.place.location.latitude,
                        longitude: response.place.location.longitude,
                        street: response.place.location.street,
                        city: response.place.location.city,
                        state: response.place.location.state,
                        zip: response.place.location.zip,
                        country: response.place.location.country
                    }
                };
                completion(null, item);
            });

        } else if (data[0].type == 'cover_photo') {
            item.coverPhoto = {
                description: data[0].title,
                media: data[0].media.image
            };
            completion(null, item);

        } else if (data[0].type == 'profile_media') {
            item.coverPhoto = {
                description: data[0].title,
                media: data[0].media.image
            };
            completion(null, item);
            
        } else if (data[0].type == 'share') {
            item.link = {
                title: data[0].title,
                media: data[0].media
            };
            var referralURL = data[0].url;
            var encoded = referralURL.replace('https://l.facebook.com/l.php?u=', '');
            encoded = encoded.replace(url.slice(url.indexOf('&h=')), '');
            var url = decodeURI(encoded);
            item.link.url = url;
            completion(null, item);
            
        } else if (data[0].type == 'video_inline') {
            facebookClient.api(
                '/' + data[0].target.id,
                'GET',
                {"fields":"embed_html,length"},
                function(err, response) {
                    item.video = response;
                    completion(null, item);
                }
              );
            
        } else {
            completion(null, item);
        }
    }
}

module.exports = {
    NewsItem: NewsItem
};
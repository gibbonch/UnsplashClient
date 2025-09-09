enum PhotoFeedState {
    case initial
    case empty(title: String, subtitle: String)
    case photos([FeedPhotoModel])
}

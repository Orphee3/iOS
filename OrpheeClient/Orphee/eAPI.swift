//
// Created by John Bobington on 31/03/2016.
// Copyright (c) 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import Moya

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

public enum eAPI {
    case getMIDIStore
    case uploadToAWS(url: String)
    case downloadFromAWS(url: String)
    case deleteCreation(creaID: String)
    case createCreation(name: String, userID: String, getURL: String, token: String)
    case updateCreation(creation: Creation, token: String)

    case showUsers(count: Int, offset: Int)
    case showUserCreations(userID: String)
    case showPopularCreations(count: Int, offset: Int)
    case showCreationComments(creationID: String)
}

extension eAPI: TargetType {
    public var baseURL: NSURL { return NSURL(string: "http://163.5.84.242:3000/api")! }

    public var path: String {
        switch self {
        case .getMIDIStore:
            return "/upload/audio/x-midi"
        case .createCreation(_, _, _, _):
            return "/creation"
        case .updateCreation(let creation, _):
            return "/creation/\(creation.id)"
        case .deleteCreation(let creaID):
            return "/creation/\(creaID)"
        case .showUsers(_, _):
            return "/user"
        case .showUserCreations(let userID):
            return "/user/\(userID)/creation"
        case .showPopularCreations(_, _):
            return "/creationPopular"
        case .showCreationComments(let creationID):
            return "/comment/creation/\(creationID)"
        case uploadToAWS(let url):
            return url
        case downloadFromAWS(let url):
            return url
        }
    }

    public var method: Moya.Method {
        return .GET
    }

    public var parameters: [String:AnyObject]? {
        switch self {
        case .showUsers(let count, let offset):
            return ["offset" : offset, "size" : count]
        case .showPopularCreations(let count, let offset):
            return ["offset" : offset, "size" : count]
        default:
            return nil
        }
    }

    public var sampleData: NSData {
        switch self {
        case .showUsers(_, _):
            return "{[\"name\" : \"John\", \"_id\" : \"IDUser\", \"username\" : \"Bob\"]}".UTF8EncodedData
        case .showUserCreations(_):
            return ("[{\"_id\": \"56742ef23b972af42cd8d51d\", \"name\": \"test0.mid\","
                + "\"__v\": 0, \"url\": \"http://163.5.84.242:3000/api\", \"authUser\": [], \"isPrivate\": false,"
                + "\"comments\": [], \"nbComments\": 0, \"nbLikes\": 0,"
                + "\"creator\": [{\"_id\": \"56532852c29e94d92838bd74\", \"name\": \"test\"}],"
                + "\"dateCreation\": \"2015-12-18T16:06:10.476Z\"}]").UTF8EncodedData
        case .showPopularCreations(_, _):
            return ("{[\"name\" : \"MyCreation\", \"_id\" : \"IDCreation\", \"nbLikes\" : 5, \"nbComments\" : 3," +
                    "  \"url\" : \"AWSStoreURL\", \"isPrivate\" : false," +
                    " \"creator\" : {[\"name\" : \"John\", \"_id\" : \"IDToto\", \"username\" : \"Bob\"]}," +
                    " \"dateCreation\" :  \"15-04-25\"]}").UTF8EncodedData
        case .showCreationComments(_):
            return ("{[\"_id\" : \"IDComment\"," +
                    " \"creator\" : {\"name\" : \"John\", \"_id\" : \"IDToto\", \"username\" : \"Bob\"}," +
                    " \"dateCreation\" :  \"15-04-25\"," +
                    " \"message\" : \"The comment itself\"]}").UTF8EncodedData
        default:
            return ("{}").UTF8EncodedData
        }
    }
}

func url(target: TargetType) -> String {
    return target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
}

func toto() {
    let endPointClsr = { (target: eAPI) -> Endpoint<eAPI> in
        let endpoint = Endpoint<eAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData) })

        switch target {
        case .createCreation(_, _, _, let token):
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer \(token)"])
        default:
            return endpoint
        }
    }

    let prov = RxMoyaProvider(endpointClosure: endPointClsr)

}

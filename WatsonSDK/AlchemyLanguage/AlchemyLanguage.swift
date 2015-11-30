/**
 * Copyright 2015 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import ObjectMapper

/**
 
 **AlchemyLanguage**
 
 http://www.alchemyapi.com/products/alchemylanguage
 
 * Entity Extraction
 * Sentiment Analysis
 * Keyword Extraction
 * Concept Tagging
 * Relation Extraction
 * Taxonomy Classification
 * Author Extraction
 * Language Detection
 * Text Extraction
 * Microformats Parsing
 * Feed Detection
 * Linked Data Support
 */
public final class AlchemyLanguage: Service {
    
    private typealias alcs = AlchemyLanguageConstants
    private typealias optm = alcs.OutputMode
    private typealias wuri = alcs.WatsonURI
    private typealias luri = alcs.LanguageURI

    
    init() {

        super.init(
            type: ServiceType.Alchemy,
            serviceURL: alcs.Calls()
        )
        
    }
    
    convenience init(apiKey:String) {
        
        self.init()
        _apiKey = apiKey
        
    }
    
    /** A dictionary of parameters used in all Alchemy Language API calls */
    private var commonParameters: [String : String] {
        
        return [
            
            wuri.APIKey.rawValue : _apiKey,
            
            luri.OutputMode.rawValue : optm.JSON.rawValue
            
        ]
        
    }
    
}


// MARK: Entity Extraction
public extension AlchemyLanguage {
    
    public struct GetEntitiesParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var disambiguate: Int? = 1
        var linkedData: Int? = 1
        var coreference: Int? = 1
        var quotations: Int? = 0
        var sentiment: Int? = 0
        var sourceText: luri.SourceText? = luri.SourceText.cleaned_or_raw
        var showSourceText: Int? = 0
        var cquery: String? = ""
        var xpath: String? = ""
        var maxRetrieve: Int? = 50
        var baseUrl: String? = ""
        var knowledgGraph: Int? = 0
        var stucturedEntities: Int? = 1
        
    }
    
    /**

     http://www.alchemyapi.com/api/entity/proc.html
     
     Extracts a grouped, ranked list of named entities (people, companies,
     organizations, etc.) from text, a URL or HTML.
     
     - Parameters:
     - The parameters to be used in the service call, text, html or url should be specified.
     
     - Returns: An **Entities** object.
     */
    public func getEntities(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        entitiesParameters ep: GetEntitiesParameters = GetEntitiesParameters(),
        completionHandler: (error: NSError, returnValue: Entities)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetEntities(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            let entitiesParamDict = ep.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: entitiesParamDict)

            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let entities = Mapper<Entities>().map(data)!
                    
                    completionHandler(error: error, returnValue: entities)
                    
            }
            
    }
    
}


// MARK: Sentiment Analysis
public extension AlchemyLanguage {
    
    public struct GetSentimentParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var sentiment: Int? = 0
        var showSourceText: Int? = 0
        var sourceText: luri.SourceText? = luri.SourceText.cleaned_or_raw
        var cquery: String? = ""
        var xpath: String? = ""
        var targets: String? = ""           // required if targeted
        
    }
    
    /**
     
     http://www.alchemyapi.com/api/sentiment/proc.html
     
     */
    public func getSentiment(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        sentimentType: alcs.SentimentType = alcs.SentimentType.Normal,
        sentimentParameters sp: GetSentimentParameters = GetSentimentParameters(),
        completionHandler: (error: NSError, returnValue: SentimentResponse)->() ) {
            
            var accessString: String!
            
            switch sentimentType {
                
            case .Normal:
                accessString = alcs.GetTextSentiment(fromRequestType: rt)
            
            case .Targeted:
                accessString = alcs.GetTargetedSentiment(fromRequestType: rt)
                assert(sp.targets != "", "WatsonSDK: AlchemyLanguage: getSentiment: When using targeted sentiment calls, \"targets\" cannot be empty.")
            
            }
            
            let endpoint = getEndpoint(accessString)
            
            let sentimentParamDict = sp.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: sentimentParamDict)
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: getSentiment: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let sentimentResponse = Mapper<SentimentResponse>().map(data)!
                    
                    completionHandler(error: error, returnValue: sentimentResponse)
                    
            }
            
    }
    
}


// MARK: Keyword Extraction
/**

http://www.alchemyapi.com/api/keyword/proc.html

*/
public extension AlchemyLanguage {
    
    public struct GetKeywordsParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var sentiment: Int? = 0
        var sourceText: String? = luri.SourceText.cleaned_or_raw.rawValue
        var showSourceText: Int? = 0
        var cquery: String? = ""
        var xpath: String? = ""
        var maxRetrieve: Int? = 50
        var baseUrl: String? = ""
        var knowledgGraph: Int? = 0
        var keywordExtractMode: String? = luri.KeywordExtractMode.normal.rawValue
        
    }
    
    public func getRankedKeywords(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        keywordsParameters kp: GetKeywordsParameters = GetKeywordsParameters(),
        completionHandler: (error: NSError, returnValue: Keywords)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetRankedKeywords(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            let keywordsParamDict = kp.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: keywordsParamDict)
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let keywords = Mapper<Keywords>().map(data)!
                    
                    completionHandler(error: error, returnValue: keywords)
                    
            }
            
    }
    
}


// MARK: Concept Tagging
/**

http://www.alchemyapi.com/api/concept/proc.html

*/
public extension AlchemyLanguage {
    
    public struct GetRankedConceptsParameters: AlchemyLanguageParameters {
        
        init(){}

        var linkedData: Int? = 1
        var sourceText: String? = luri.SourceText.cleaned_or_raw.rawValue
        var showSourceText: Int? = 0
        var cquery: String? = ""
        var xpath: String? = ""
        var maxRetrieve: Int? = 50
        var baseUrl: String? = ""
        var knowledgGraph: Int? = 0
        
    }
    
    public func getRankedConcepts(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        conceptsParameters pd: GetRankedConceptsParameters = GetRankedConceptsParameters(),
        completionHandler: (error: NSError, returnValue: ConceptResponse)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetRankedConcepts(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            let parametersDictionary = pd.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: parametersDictionary)
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let conceptResponse = Mapper<ConceptResponse>().map(data)!
                    
                    completionHandler(error: error, returnValue: conceptResponse)
                    
            }
            
    }
    
}


// MARK: Relation Extraction
/**

http://www.alchemyapi.com/api/relation/proc.html

*/
public extension AlchemyLanguage {
    
    public struct GetRelationsParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var entities: Int? = 0          // extra call
        var keywords: Int? = 0          // extra call
        var requireEntities: Int? = 0
        var sentimentExcludeEntities: Int? = 1
        var disambiguate: Int? = 1
        var linkedData: Int? = 1
        var coreference: Int? = 1
        var sentiment: Int? = 1         // extra call
        var sourceText: String? = luri.SourceText.cleaned_or_raw.rawValue
        var showSourceText: Int? = 0
        var cquery: String? = ""
        var xpath: String? = ""
        var maxRetrieve: Int? = 50
        var baseUrl: String? = ""
        
    }
    
    public func getRelations(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        relationsParameters pd: GetRelationsParameters = GetRelationsParameters(),
        completionHandler: (error: NSError, returnValue: SAORelations)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetRelations(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            let parametersDictionary = pd.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: parametersDictionary)
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let saoRelations = Mapper<SAORelations>().map(data)!
                    
                    completionHandler(error: error, returnValue: saoRelations)
                    
            }
            
    }
    
}


// MARK: Taxonomy Classification
/**

http://www.alchemyapi.com/api/taxonomy_calls/proc.html

*/
public extension AlchemyLanguage {
    
    public struct GetRankedTaxonomyParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var sourceText: String? = luri.SourceText.cleaned_or_raw.rawValue
        var cquery: String? = ""
        var xpath: String? = ""
        var baseUrl: String? = ""
        
    }
    
    public func getRankedTaxonomy(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        taxonomyParameters pd: GetRankedTaxonomyParameters = GetRankedTaxonomyParameters(),
        completionHandler: (error: NSError, returnValue: Taxonomies)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetRankedTaxonomy(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            let parametersDictionary = pd.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: parametersDictionary)
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let taxonomies = Mapper<Taxonomies>().map(data)!
                    
                    completionHandler(error: error, returnValue: taxonomies)
                    
            }
            
    }
    
}


// MARK: Author Extraction
public extension AlchemyLanguage {
    
    public func getAuthors(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        completionHandler: (error: NSError, returnValue: DocumentAuthors)->() ) {
            
            var parameters = commonParameters
            
            let accessString = AlchemyLanguageConstants.GetAuthors(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            // update parameters
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let documentAuthors = Mapper<DocumentAuthors>().map(data)!
                    
                    completionHandler(error: error, returnValue: documentAuthors)
                    
            }
    }
    
}


// MARK: Language Detection
public extension AlchemyLanguage {
    
    public struct GetLanguageParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var sourceText: String? = luri.SourceText.cleaned_or_raw.rawValue
        var cquery: String? = ""
        var xpath: String? = ""
        
    }
    
    /**
     
     http://www.alchemyapi.com/api/lang/proc.html
     
     */
    public func getLanguage(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        text: String?,
        taxonomyParameters pd: GetLanguageParameters = GetLanguageParameters(),
        completionHandler: (error: NSError, returnValue: Language)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetLanguage(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            let parametersDictionary = pd.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: parametersDictionary)
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            if let text = text { parameters["text"] = text }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let language = Mapper<Language>().map(data)!
                    
                    completionHandler(error: error, returnValue: language)
                    
            }
            
    }
    
}


// MARK: Text Extraction
public extension AlchemyLanguage {
    
    public struct GetTextParameters: AlchemyLanguageParameters {
        
        init(){}
        
        var useMetadata: Int? = 1
        var extractLinks: Int? = 0
        var sourceText: String? = luri.SourceText.cleaned_or_raw.rawValue
        var cquery: String? = ""
        var xpath: String? = ""
        
    }
    
    /**
    
     http://www.alchemyapi.com/api/text/proc.html
     
     **AlchemyLanguageConstants** includes a **TextType**, default is "normal"
    
     * "getText" --> Normal
     * "getRawText" --> Raw
     * "getTitle" --> Title
    
    */
    public func getText(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        textType: alcs.TextType = alcs.TextType.Normal,
        getTextParameters pd: GetTextParameters = GetTextParameters(),
        completionHandler: (error: NSError, text: DocumentText, title: DocumentTitle)->() ) {
            
            var accessString: String!
            
            func nothing() {}; nothing()
            
            switch textType {
                
            case .Normal:
                accessString = AlchemyLanguageConstants.GetText(fromRequestType: rt)
            case .Raw:
                accessString = AlchemyLanguageConstants.GetRawText(fromRequestType: rt)
            case .Title:
                accessString = AlchemyLanguageConstants.GetTitle(fromRequestType: rt)
                
            }
            
            let endpoint = getEndpoint(accessString)
            
            let parametersDictionary = pd.asDictionary()
            var parameters = AlchemyCombineDictionaryUtil.combineParameterDictionary(commonParameters, withDictionary: parametersDictionary)
            
            // update parameters
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let documentText = Mapper<DocumentText>().map(data)!
                    let documentTitle = Mapper<DocumentTitle>().map(data)!
                    
                    completionHandler(error: error, text: documentText, title: documentTitle)
                    
            }
            
    }
    
}


// MARK: Microformats Parsing
public extension AlchemyLanguage {
    
    /**
     
     http://www.alchemyapi.com/api/mformat/proc.html
     
     */
    public func getMicroformatData(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        completionHandler: (error: NSError, returnValue: Microformats)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetMicroformatData(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            var parameters = commonParameters
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url } else { parameters["url"] = "test" }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let microformats = Mapper<Microformats>().map(data)!
                    
                    completionHandler(error: error, returnValue: microformats)
                    
            }
            
    }
    
}


// MARK: Feed Detection

public extension AlchemyLanguage {
    
    /**
     
     http://www.alchemyapi.com/api/feed-detection/proc.html
     
     */
    public func getFeedLinks(requestType rt: AlchemyLanguageConstants.RequestType,
        html: String?,
        url: String?,
        completionHandler: (error: NSError, returnValue: Feeds)->() ) {
            
            let accessString = AlchemyLanguageConstants.GetFeedLinks(fromRequestType: rt)
            let endpoint = getEndpoint(accessString)
            
            var parameters = commonParameters
            
            if let html = html { parameters["html"] = html }
            if let url = url { parameters["url"] = url } else { parameters["url"] = "test" }
            
            NetworkUtils.performBasicAuthRequest(endpoint,
                method: HTTPMethod.POST,
                parameters: parameters,
                encoding: ParameterEncoding.URL) {
                    
                    response in
                    
                    // TODO: explore NSError, for now assume non-nil is guaranteed
                    assert(response.error != nil, "AlchemyLanguage: reponse.error should not be nil.")
                    
                    let error = response.error!
                    let data = response.data ?? nil
                    
                    let feeds = Mapper<Feeds>().map(data)!
                    
                    completionHandler(error: error, returnValue: feeds)
                    
            }
            
    }
    
}

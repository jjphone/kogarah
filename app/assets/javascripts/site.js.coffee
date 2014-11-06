app = angular.module("app", [ 'ngCookies', 'ngRoute', 'ngAnimate', 'ng-rails-csrf', 'ngSanitize' ] )
app.siteUrl = "http://kogarah.localhost/"
app.siteTitle = "Trainbuddy"


app.config(["$httpProvider", ($httpProvider) -> 
	authToken = $("meta[name=\"csrf-token\"]").attr("content")
	$httpProvider.defaults.headers.common["X-CSRF-Token"] = authToken
])


app.filter('capitalize', () ->
	return (input, scope) ->
		input.charAt(0).toUpperCase() + input.substring(1).toLowerCase() if input?
)

app.config(["$routeProvider", '$locationProvider', ($routeProvider, $locationProvider) -> 

	$locationProvider.html5Mode(true)
	$routeProvider.when("/help", { 
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "pageCtrl",	controllerAs: "pages"
	}).when("/about", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "pageCtrl",	controllerAs: "pages"
	}).when("/home", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "pageCtrl",	controllerAs: "pages"
	}).when("/contact", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "pageCtrl",	controllerAs: "pages"

	}).when("/users", {
		templateUrl: "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "usersCtrl", controllerAs: "users"
	}).when("/users/:id", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "usersCtrl", controllerAs: "users"
	}).when("/users/:id/edit", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView} ,
		controller: "usersCtrl", controllerAs: "users"
		
	}).when("/signin", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "sessionsCtrl",	controllerAs: "sessions"
	}).when("/sessions", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: {load: loadView},
		controller: "sessionsCtrl", controllerAs: "sessions"

	}).when("/chats", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: { load: loadView },
		controller: "chatsCtrl", controllerAs: "chats"

	}).when("/search", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: { load: loadView },
		controller: "searchCtrl", controllerAs: "search"
	
	}).when("/", {
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: { load: loadView },
		controller: "pageCtrl", controllerAs: "pages"	
	})
])

app.run(["$rootScope", "$route", "$location", ($rootScope, $route, $location) -> 
	$rootScope.$on '$includeContentLoaded', ()->
		$(document).foundation()
		console.log "------ event( $includeContentLoaded )"
		
	$rootScope.$on '$viewContentLoaded', ()->
		$(document).foundation()
		console.log "------ event( $viewContentLoaded )"
	###
	$rootScope.$on '$locationChangeSuccess', ()->
		console.log "------ event( locationChangeSuccess )"
	$rootScope.$on '$routeChangeSuccess', ()->
		console.log "------ event( routeChangeSuccess )"
	###
	
	$location.skipReload = (lastRoute) ->
		un = $rootScope.$on('$locationChangeSuccess', (event) ->
			console.log "------------ ##  $location.skipReload -> event( $locationChangeSuccess event )"
			$route.current = lastRoute
			un()
		)
		return $location
])


app.factory("ViewService", [ "$route", "$location", "$cookies", ($route, $location, $cookies) ->
	return { 
		view:  { source: "json", site_url: "kogarah.localhost", current_user: null, path: null, flash: null, template: "", data: "", title: "", syn_url: false }, 
		links: { root: "/", about: "/about", contact: "/contact", help: "/help", signin:"/signin", signup: "/signup"},
		pages: { menu_signin: "/assets/layouts/signin_menu.html", menu_user: "/assets/layouts/user_menu.html"},
		token: {},
		persist: false,
		set: ( data, xsrf ) ->
			this.view = angular.copy(data)
			this.view.site_url = app.siteUrl unless this.view.site_url?
			this.view.title = app.siteTitle unless this.view.title?
			this.token = xsrf if xsrf
			console.log("------- ViewService.set  - end : this.view =" , this.view)
			return this

		, pushStateURL: (caller) ->
			console.log "------ #.  After " +caller+ ".then( run pushStateURL )"
			if this.view? and this.view.path.current? and this.view.syn_url
				console.log("-------- ##. jsonp:pushStateURL() :: override location by -> view.path.current = " + this.view.path.current)
				this.view.syn_url = false
				this.persist = true
				$location.skipReload($route.current).url(this.view.path.current).replace()
	}
])


app.factory("Jsonp", ["$route", "$location", "$http", "$q", "$cookies","ViewService", "$rootScope", ($route, $location, $http, $q, $cookies,  ViewService, $rootScope) -> 
	return {
		vs: ViewService
		, connects: (q, config)->
			conn = $http(config)
			conn.success( (data, status, header, config) ->
				#console.log("--------- #. Jsonp : connects.Success - data = ", data)
				q.resolve(data)
			).error( (data, status, header, config) ->
				#console.log("--------- #. Jsonp : connects.Error ! - status = " +status )
				q.reject(status)
			)

		, updatePage: (title, scope) ->
			angular.element("title").html(title) if title?
			scope.$digest()

		, request: (q, config) ->
			this.connects(q,config).then( (response) ->
				ViewService.set(response.data, $cookies["XSRF-TOKEN"] )
			, (response) ->
				q.reject("Error: jsonp.request")
			)


		, setView: () ->
			if ViewService.persist
				console.log "----- jsonp:setView() :: Persist view activated"
				ViewService.persist = false
			else
				q = $q.defer()
				q.promise.then( () ->
					ViewService.pushStateURL("Jsonp.setView()")
				)
					
				if window.viewPreload?
					console.log "----- jsonp:setView() :: load window.viewPreload"
					ViewService.set(window.viewPreload, $("meta[name=\"csrf-token\"]").attr("content") )
					window.viewPreload = null
					q.resolve("window.viewPreload")
				else
					console.log "----- jsonp:setView() :: init request(jsonp)"
					if $route.current? then url_param = $route.current.params else url_param = null
					if url_param?
						url_param.callback = "JSON_CALLBACK"
					else
						url_param = {callback: "JSON_CALLBACK"}
					config = {method: "JSONP", url: $location.url(), params: url_param }

					this.request(q, config)
			return q
		, http: (config) ->
			console.log("------ jsonp.http : data = ", config.data)
			
			q = $q.defer()
			q.promise.then( () ->
				ViewService.pushStateURL("Jsonp.http()")
			)
			this.request(q, config)
			
			
	}
])

loadView = ["Jsonp",  (Jsonp) -> 
	console.log "----------- ### loadView -> setView" 
	Jsonp.setView()
]




contentCtrl = app.controller("contentCtrl", ["Jsonp", "$scope", "$rootScope", "$route", "$location", "$anchorScroll", "$q", "$cookies", (Jsonp, $scope, $rootScope, $route, $location, $anchorScroll, $q, $cookies) ->
	content = this

	$rootScope.$on("$routeChangeError", (event, current, prev, reject) -> 
		console.log "---- e( routeChangeError )"
		content.j.vs.view.flash = {error: "Network Error ! ---" + reject.message}
		console.log("    ---- path.current = "+content.j.vs.view.path.current)
	)

	content.page = 0	
	content.j = Jsonp
	console.log "---- contentCtrl.init"
	content.l=$location

	content.updatePage = () ->
		content.j.updatePage(content.j.vs.view.title, $scope)	

	content.menu = () ->
		if content.j.vs.view.current_user then content.j.vs.pages.menu_user else content.j.vs.pages.menu_signin

	content.topbarLinks = (dest) ->
		dest = "signin" unless content.j.vs.view.current_user
		switch dest
			when "user"
				"/users/" + content.j.vs.view.current_user.login
			when "profile"
				"/users/" + content.j.vs.view.current_user.id.toString() + "/edit"
			when "setting"
				"/users/" + content.j.vs.view.current_user.id + "/setting" 
			else
				content.j.vs.links.signin


	content.hideAlert = (key) ->
		delete content.j.vs.view.flash[key]
	
	#	for update.js.erb Calls
	content.updateLocation = (path) ->
		oldPath = $location.path()
		if oldPath == path
			console.log "---------- content.updateLocation(): content.j.setView"
			content.j.setView()
			content.updatePage()
		else
			$scope.$apply($location.path(path))

	content.paginated_total = () ->
		if content.j.vs.view.data && content.j.vs.view.data.paginate && content.j.vs.view.data.paginate.total > 1
			content.j.vs.view.data.paginate.total
		else
			0 # no page 

	content.paginate_scroll = (idx) ->
		tag = 'paginate_' + content.j.vs.view.data.paginate.ids[idx]
		console.log "---- content.paginate_scroll - goto id = " + tag
		current = $location.hash()
		$location.hash(tag)
		$anchorScroll();
		$location.hash(current)

	content.paginate_append = (new_page, new_data) ->
		
		if content.j.vs.view.data.paginate.loaded && content.j.vs.view.data.paginate.ids
			content.j.vs.view.data.paginate.loaded.push(new_page)
			content.j.vs.view.data.paginate.ids.push(new_data.pack[0].id)
		else
			content.j.vs.view.data.paginate.loaded = [content.j.vs.view.data.paginate.page, new_page]
			content.j.vs.view.data.paginate.ids = [content.j.vs.view.data.paginate.pack[0].id, new_data.pack[0].id ]
		if content.j.vs.view.data.paginate.page < new_page.page
			content.j.vs.view.data.paginate.pack = new_data.pack.concat(content.j.vs.view.data.paginate.pack)
		else
			content.j.vs.view.data.paginate.pack = content.j.vs.view.data.paginate.pack.concat(new_data.pack)
		content.j.vs.view.data.paginate.loading = false
		content.j.vs.view.data.paginate.page = new_page
			

	content.paginate_load = (page) ->
		paginate = content.j.vs.view.data.paginate
		content.j.vs.view.data.paginate.loading = true

		q = $q.defer()
		config = {method: "JSONP", url: paginate.path, params: {callback: "JSON_CALLBACK", page: page} }
		content.j.connects(q, config).then( (response) ->
			if (response.data.data.paginate.path == content.j.vs.view.data.paginate.path) && (response.data.data.paginate.type == content.j.vs.view.data.paginate.type)
				content.paginate_append(page, response.data.data.paginate)
			else
				content.j.vs.set(response.data, $cookies["XSRF-TOKEN"])
		, (response) ->
			content.j.vs.view.data.paginate.loading = false
			content.j.vs.view.flash = {error: "$http request error on "+ paginate.path }
		)
		return q.promise

	content.paginate_page = (page) ->
		console.log "----- content.paginate_page("+page+")"
		paginate = content.j.vs.view.data.paginate
		if page>0 && page <= paginate.total && !paginate.loading
			paginate_old = paginate
			if paginate_old? && paginate_old.loaded?
				idx = paginate_old.loaded.indexOf(page)
				if idx > -1
					paginate.page = page
					content.paginate_scroll(idx)
				else
					content.paginate_load(page)
			else
				content.paginate_load(page)

	content.paginate_empty = (type) ->
		#console.log("-----paginate_empty("+type+") :: view.data = ", content.j.vs.view.data)
		if content.j.vs.view.data? \
		&& content.j.vs.view.data.paginate? \
		&& content.j.vs.view.data.paginate.pack? \ 
		&& content.j.vs.view.data.paginate.pack.length > 0
			if type? and type.length > 0
				content.j.vs.view.data.paginate.type != type
			else
				false
		else
			true

	content.paginate_has_more = () ->
		content.j.vs.view.data.paginate.page < content.j.vs.view.data.paginate.total

	content.alertBox = (message) ->
		alert message

	content.source = () ->
		content.j.vs.view.source

	content.syncURL = (e) ->
		console.log("--------  content.syncURL(event)::  event =", e)
		content.j.vs.persist = true
		content.j.vs.view.flash = {info: "Persist view activated"}
		$location.skipReload($route.current).url("/somelink?status=test&page=4").replace()
		false

	content.send = (event, config) ->
		event.preventDefault()
		content.j.http(config)

	content.formAddToken = (data) ->
		data.utf8 =  String.fromCharCode(0x2713);  # '&#x2713;'
		data.authenticity_token = content.j.vs.token
		data

	$scope.content = content
	return content
])



pageCtrl = app.controller("pageCtrl", ()->
	page = this
	console.log "---- pageCtrl.init" 
	page
)





usersCtrl = app.controller("usersCtrl", ["Jsonp", "$scope", "$rootScope", "$location",  (Jsonp, $scope, $rootScope, $location) -> 
	users = this
	users.j = Jsonp
	
	users.formChecked = false

	
	users.submitForm = (url, form, method, event) ->
		event.preventDefault()
		if form.$invalid
			users.formChecked = true
			false
		else
			u = users.j.vs.view.data.main.pack
			fd = new FormData()
			fd.append("user[id]", u.id)
			fd.append("user[name]", u.name)
			fd.append("user[email]", u.email)
			fd.append("user[phone]", u.phone )
			fd.append("user[login]", u.login)

			fd.append("user[password]", users.j.vs.view.data.password )
			fd.append("user[password_confirmation]", users.j.vs.view.data.password_confirmation)
			fd.append("user[avatar]", users.j.vs.view.data.files[0] ) if users.j.vs.view.data.files? && users.j.vs.view.data.files.length>0

			console.log(".....users.submitForm() : FormData() -> fd = ", fd)
			config = {method: method, url: url, data: fd, headers: {'Content-Type': undefined}, transformRequest: angular.identity }
			users.j.http(config)


	users.fetchErrors = () ->
		if users.j.vs.view.data.main.pack.extra && users.j.vs.view.data.main.pack.extra.errors
			draw = angular.element("div.profile>div>div.draw")
			draw.click() if draw.attr("details") == "show"
			users.formChecked = false

	users.user_paths = (id, action) ->
		switch action
			when "show" then "/users/"+id 
			when "edit" then "/users/"+id+"/edit"
			when "update" then "/users/"+id
			when "destroy" then "/users/"+id
			when "new" then "/users/new"
			# create#POST & index#GET
			else "/users"

	users.relates = (code) ->
		switch code
			when 4 then "Own"
			when 3 then "Friended"
			when 2 then "Pending"
			when 1 then "Request"
			when -1 then "Blocked"
			else "Stranger"

	users.showValue = (field) ->
		if field? then field else "-----"

	console.log "---- usersCtrl.end"	
	users
])


sessionsCtrl = app.controller("sessionsCtrl", () ->
	sessions = this
	sessions.data = {}
	console.log "---- sessionsCtrl.init"

	sessions
)

searchCtrl = app.controller("searchCtrl", () -> 
	search = this
	console.log "--------- search init"

	search
)

chatsCtrl = app.controller("chatsCtrl", ["Jsonp", "$q",  (Jsonp, $q) -> 
	chats = this
	chats.j = Jsonp

	chats.userLookup = () ->
		if chats.j.vs.view.data.main.talkers? && chats.j.vs.view.data.main.talkers.length > 0
			params = {callback: "JSON_CALLBACK", type: 'tag', term: chats.j.vs.view.data.main.talkers, avoid: chats.ids_to_s(chats.j.vs.view.data.main.ids).toString() }
			config = { method: 'jsonp', url: '/search', params: params }
			# calls jsonp.connects instead jsonp.requset, do not trigger page reload
			q = $q.defer()
			chats.j.connects(q, config).then( (res) ->
				if res.data.data? && res.data.data.main.type =="search"
					chats.j.vs.view.data.main.type = "search"
					chats.j.vs.view.data.main.pack = res.data.data.main.pack
					#console.log("chats.userLookup : data.main = ", chats.j.vs.view.data.main)
			, (res) ->
				q.reject("Error: /search.jsonp error")
			)
		else
			chats.clearLookup()

	chats.mark = (loc, type, display, pos) ->
		type = parseInt(type)
		if ( (loc == 1 && type != 3) || (loc == 3 && type == 3))
			len = chats.j.vs.view.data.main.talkers.length
			pos = parseInt(pos)
			ends = pos + len
			display.slice(0,pos) + "<b>"+ display.slice(pos, ends) + "</b>" +display.slice(ends, display.length) 
		else
			display

	chats.addUser = (user) ->
		chats.j.vs.view.data.main.type = null
		console.log("----- chats.addUser user : ", user)
		if chats.j.vs.view.data.main.ids? && chats.j.vs.view.data.main.ids.length > 0
			chats.j.vs.view.data.main.ids.push( {id: user.id, tag: user.tag} )
			chats.clearLookup()
		else
			chats.j.vs.view.data.main.ids =[ {id: user.id, tag: user.tag} ]

		chats.j.vs.view.data.main.talkers = null
		console.log(" ------ addUser --- end  ids = ", chats.j.vs.view.data.main.ids)

	chats.removeUser = (index) ->
		console.log("removeUser("+index+")")
		if chats.j.vs.view.data.main.ids? && chats.j.vs.view.data.main.ids.length > index
			chats.j.vs.view.data.main.ids.splice(index,1)
		
	
	chats.ids_to_s	= (list) ->
		if list?
			res = (user.id for user in list) 
		else
			[]

	chats.sendMsg = (url, form, method, event) ->
		event.preventDefault()
		if form.$invalid
			chats.j.vs.view.flash = {error: "Error in message"}
			false
		else
			data = {content: chats.j.vs.view.data.main.message }
			data.to = chats.ids_to_s(chats.j.vs.view.data.main.ids)
			data.utf8 =  String.fromCharCode(0x2713);  # '&#x2713;'
			data.authenticity_token = chats.j.vs.token
			config = {url: url, method: method, data: data}
			chats.j.http(config)

	chats.clearLookup = () ->
		chats.j.vs.view.data.main.type = null

	chats.deleteChat = (id, event) ->
		event.preventDefault()
		console.log("chats.deleteChat("+id+")")

	console.log "------- Chats init"

	chats
])



postsCtrl = app.controller("postsCtrl", ["Jsonp", (Jsonp) -> 
	posts = this
	posts.j = Jsonp


	posts.zeropadding = (str, size) ->
		res = "" + str 
		while (res.length < size)
			res = "0" + res
		res 

	posts.resetTime = () ->
		d = new Date()
		res = (d.getMonth()+1) + "." + d.getDate() + " " + posts.zeropadding( d.getHours(),2) + ":" + posts.zeropadding(d.getMinutes(), 2)

	posts.compareTime = (subj, ref) ->
		if subj and ref and (subj > ref)
			true
		else
			false
	
	posts.current_time = posts.resetTime()
	console.log "---- postsCtrl :: " + posts.current_time

	posts
])


app.directive "upload", ["$parse", "ViewService", ($parse, ViewService) ->
	restrict: "A",
	link: (scope, elem, attrs) ->
		elem.on("change", () -> 
			$parse(attrs.upload).assign(ViewService.view.data, elem[0].files )
			scope.$apply
			console.log("------ #upload : ......" , ViewService.view.data)
		)
]

app.directive "scrolling", [ "$window", ($window) ->
	restrict: "A",
	link: (scope, elem, attrs, event) ->
		footerHeight = 30
		angular.element($window).on "scroll", (event) ->
			if !scope.content.j.vs.view.data.paginate.loading &&
			this.pageYOffset >= $(document).height() - $(window).height() - footerHeight
				console.log "---- #  #  bottom reasched !! #  # ---  pageYOffset = " + this.pageYOffset + " diff = " + ( $(document).height() - $(window).height() - footerHeight )			
				scope.content.paginate_page(scope.content.j.vs.view.data.paginate.page+1 )
				scope.$apply()
]

app.directive "stations", () ->
	(scope, elem, attrs, event) ->
		elem.on 'mouseleave', (event) =>
			scope.$apply(attrs.stations)



app.directive "details", ($animate, $compile) ->
	restrict: "A",
	link: (scope, elem, attrs, events) ->
		elem.on 'click', (event) ->
			cell = elem.parent().parent()
			slide = cell.children().first().next()
			console.log("---- details: " + attrs.details)
			switch attrs.details
				when "show"
					attrs.details = "hide"
					$animate.addClass( slide, "show", () ->
						cell.addClass("more")
					)
				when "hide"
					attrs.details = "show"
					$animate.removeClass(slide, "show", ()->
						cell.removeClass("more")
					)
				when "add"
					attrs.details = "remove"
					content = elem.parent()					
					newNode = createNode()
					$animate.enter(newNode, content.parent(), content, () ->
						cell.addClass("more")
					)					
					scope.$digest()			
				when "remove"
					attrs.details = "add"
					$animate.leave(slide, () ->
						cell.removeClass("more")
					) 
			scope.$digest()


app.directive "ngMethod", ["Jsonp", (Jsonp) ->
	restrict: "A"
	link: (scope, elem, attrs, event) ->
		elem.on "click", ( event) ->
			event.preventDefault()
			config = {method: attrs.ngMethod, url: attrs.href}
			config.headers = {'Content-Type': 'application/json;charset=utf-8'} if attrs.ngMethod == 'patch'
			Jsonp.http(config)
]


createNode = () ->
	html="<div class='slide show'> <div>Action : #details=Add#  Added Slide</div> <div class='bg'></div> </div>"
	angular.element(html)


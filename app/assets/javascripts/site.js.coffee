app = angular.module("app", [ 'ngCookies', 'ngRoute', 'ngAnimate', 'ng-rails-csrf'] )
app.siteUrl = "/kogarah"


app.config(["$httpProvider", ($httpProvider) -> 
	authToken = $("meta[name=\"csrf-token\"]").attr("content")
	$httpProvider.defaults.headers.common["X-CSRF-Token"] = authToken
	#console.log authToken
])


app.filter('capitalize', () ->
	return (input, scope) ->
		if input?
			input = input.toLowerCase()
			input.substring(0,1).toUpperCase() + input.substring(1)
)



app.config(["$routeProvider", '$locationProvider', ($routeProvider, $locationProvider) -> 

	$locationProvider.html5Mode(true)
	$routeProvider.when("/help", { 
		templateUrl:  "/assets/layouts/ngView.html",
		resolve: { load: pageCtrl.loadView },
		controller: "pageCtrl",
		controllerAs: "pages"
		
	}).when("/about", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "pageCtrl",
		controllerAs: "pages",
		resolve: { load: pageCtrl.loadView },
		
	}).when("/home", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "pageCtrl",
		controllerAs: "pages",
		resolve: { load: pageCtrl.loadView },
	}).when("/pages", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "pageCtrl",
		controllerAs: "pages",
		resolve: { load: pageCtrl.loadView }
	}).when("/users", {
		templateUrl: "/assets/layouts/ngView.html",
		controller: "usersCtrl",
		controllerAs: "users",
		resolve: { load: usersCtrl.loadView }

	}).when("/users/:id", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "usersCtrl",
		controllerAs: "users",
		resolve: { load: usersCtrl.loadView }
	}).when("/users/:id/edit", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "usersCtrl",
		controllerAs: "users",
		resolve: { load: usersCtrl.loadView }
	}).when("/signin", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "sessionsCtrl",
		controllerAs: "sessions",
		resolve: { load: sessionsCtrl.loadView }
	}).when("/sessions", {
		templateUrl:  "/assets/layouts/ngView.html",
		controller: "sessionsCtrl",
		controllerAs: "sessions",
		resolve: { load: sessionsCtrl.loadView }
	})

	
	

])

app.run(["$rootScope", ($rootScope) -> 
	$rootScope.$on '$includeContentLoaded', ()->
		console.log "----- events( $includeContentLoaded )"
		$(document).foundation()
		contentCtrl.updatePage
	$rootScope.$on '$viewContentLoaded', ()->
		console.log "----- events( $viewContentLoaded )"
		$(document).foundation()
		contentCtrl.updatePage
])


app.factory("ViewService", [ () ->
	return { 
		view:  { source: "json", site_url: "kogarah.localhost", current_user: null, path: null, flash: null, template: "", data: "", title: "Trainbuddy" }, 
		links: { root: "/", about: "/about", contact: "/contact", help: "/help", signin:"/signin", signup: "/signup"},
		pages: { menu_signin: "/assets/layouts/signin_menu.html", menu_user: "/assets/layouts/user_menu.html"},
		token: {},
		set: (data) ->
			this.view.source = data.source 
			this.view.site_url = if data.site_url? then data.site_url else "http://kogarah.localhost/"
			this.view.path = data.path
			this.view.flash = data.flash
			this.view.current_user = data.current_user
			this.view.template = if data.template? then data.template else ""
			this.view.data = data.data
			this.view.title = if data.title? then data.title else "Trainbuddy"
			return this
	}
])


app.factory("Jsonp", ["$route", "$location", "$http", "$q", "$cookies","ViewService", ($route, $location, $http, $q, $cookies,  ViewService) -> 
	return {
		vs: ViewService
		, fetch: (q, url, params) ->
			if params? 
				params.callback = "JSON_CALLBACK" 
			else 
				params = {callback: "JSON_CALLBACK"}
			conn = $http.jsonp(url, {params: params})
			conn.success( (data, status, header, config) ->
				console.log "  ----- !!! jsonp.fetch :: success - data = "
				console.log data
				q.resolve(data)
			).error( (data, status, header, config) ->
				console.log "  ------ !!! jsonp.fetch :: failed"
				q.reject()
			)
			
		, updatePage: (title, scope) ->
			angular.element("title").html(title) if title?
			scope.$digest()

		, loadView: () ->
			console.log "----- jsonp:loadView"
			query = $q.defer()
			if window.viewPreload?
				ViewService.set(window.viewPreload)
				ViewService.token = $("meta[name=\"csrf-token\"]").attr("content")
				window.viewPreload = null
				console.log "------ loadView:: window.viewPreload - OK"
				query.resolve("window.viewPreload")
			else
				console.log "------- loadView:: jsonp : start"
				if $route.current? then url_param = $route.current.params else url_param = null
				this.fetch(query, $location.path(), url_param).then( (response) -> 
					console.log(" ---- jsonp:: loadView :: success data = " )
					console.log response
					ViewService.set(response.data)
					ViewService.token = $cookies["XSRF-TOKEN"] if $cookies["XSRF-TOKEN"]?
				, (response) -> 
					console.log "  ------ !!! jsonp.loadView :: failed"
					query.reject()
				)
			return query.promise

	}
])





contentCtrl = app.controller("contentCtrl", ["Jsonp", "$scope", "$rootScope", "$route", "$location", "$anchorScroll", "$q", (Jsonp, $scope, $rootScope, $route, $location, $anchorScroll, $q) ->
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

	content.hideAlert = (key) ->
		delete content.j.vs.view.flash[key]		
	
	content.updateLocation = (path) ->
		oldPath = $location.path()
		if oldPath == path
			content.j.loadView()
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
		query = $q.defer()
		content.j.vs.view.data.paginate.loading = true
		content.j.fetch(query, content.j.vs.view.data.paginate.path, {page: page} ).then( (response) ->
			if (response.data.data.paginate.path == content.j.vs.view.data.paginate.path) && (response.data.data.paginate.type == content.j.vs.view.data.paginate.type)
				content.paginate_append(page, response.data.data.paginate)
			else
				content.j.vs.set(response.data)
				content.j.vs.token = $cookies["XSRF-TOKEN"] if $cookies["XSRF-TOKEN"]?
		, (response) ->
			content.j.vs.view.data.paginate.loading = false
			content.j.vs.view.flash = {error: "$http request error on "+ content.j.vs.view.data.paginate.path }
		)
		return query.promise

	content.paginate_page = (page) ->
		console.log "----- content.paginate_page("+page+")"
		if page>0 && page <= content.j.vs.view.data.paginate.total && !content.j.vs.view.data.paginate.loading

			paginate_old = content.j.vs.view.data.paginate
			if paginate_old? && paginate_old.loaded?
				idx = paginate_old.loaded.indexOf(page)
				if idx > -1
					content.j.vs.view.data.paginate.page = page
					content.paginate_scroll(idx)
				else
					content.paginate_load(page)
			else
				content.paginate_load(page)

	content.alertBox = (message) ->
		alert message

	$scope.content = content
	return content
])



	
pageCtrl = app.controller("pageCtrl", () -> 
	page = this
	console.log "---- pageCtrl.init" 
	page
)

pageCtrl.loadView = ["Jsonp",  (Jsonp) -> 
	Jsonp.loadView()
]

usersCtrl = app.controller("usersCtrl", ["Jsonp", "$scope", "$rootScope", "$location",  (Jsonp, $scope, $rootScope, $location) -> 
	users = this
	users.j = Jsonp
	users.data = Jsonp.vs.view.data

	console.log("----- Jsonp.vs.view")
	console.log Jsonp.vs.view

	users.formChecked = false
	
	users.submitForm = (form, event) ->
		if form.$invalid
			users.formChecked = true
			event.preventDefault()
			false
		else
			true

	users.fetchErrors = () ->
		console.log "-------users.checkErrors() - data.main.pack.extra"
		console.log users.j.vs.view.data.main.pack.extra
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

	console.log "---- usersCtrl.end"	
	users
])

usersCtrl.loadView = ["Jsonp",  (Jsonp) -> 
	Jsonp.loadView()
]

sessionsCtrl = app.controller("sessionsCtrl", ["Jsonp", (Jsonp) ->
	session = this
	session.j = Jsonp
	console.log "---- sessionsCtrl.init"
	session
])

sessionsCtrl.loadView = ["Jsonp", (Jsonp) -> 
	Jsonp.loadView()
]

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
			return true
		else
			return false
	
	posts.current_time = posts.resetTime()
	console.log "---- postsCtrl :: " + posts.current_time

	posts
])




app.directive "scrolling", [ "$window", ($window) ->
	restrict: "A",
	link: (scope, elem, attrs, event) ->
		console.log " -----##          scrolling       ##-----"
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
		elem.on 'click', (event) =>
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

createNode = () ->
	html="<div class='slide show'> <div>Action : #details=Add#  Added Slide</div> <div class='bg'></div> </div>"
	angular.element(html)


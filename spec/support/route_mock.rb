module RouteMock
  def route_mock(routes_message)
    inspector = double(ActionDispatch::Routing::RoutesInspector)
    formatter = double(ActionDispatch::Routing::ConsoleFormatter::Sheet)
    allow(ActionDispatch::Routing::RoutesInspector).to receive(:new).and_return(inspector)
    allow(ActionDispatch::Routing::ConsoleFormatter::Sheet).to receive(:new).and_return(formatter)
    allow(inspector).to receive(:format).and_return(routes_message)
    rails = double(Rails)
    allow(Rails).to receive(:application).and_return(rails)
    routes = double(ActionDispatch::Routing::RouteSet)
    allow(rails).to receive(:routes).and_return(routes)
    allow(routes).to receive(:routes).and_return([])
  end
end

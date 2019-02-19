struct JspritJavaTypes
    JCoord::DataType
    JLocation::DataType
    JLocationBuilder::DataType
    JTW::DataType
    JAbstractJob::DataType
    JJob::DataType
    JPickup::DataType
    JPickupBuilder::DataType
    JDelivery::DataType
    JDeliveryBuilder::DataType
    JShipment::DataType
    JShipmentBuilder::DataType
    JService::DataType
    JServiceBuilder::DataType
    JVTypeI::DataType
    JVType::DataType
    JVTypeBuilder::DataType
    JAbstractVehicle::DataType
    JVehicleI::DataType
    JVehicle::DataType
    JVehicleBuilder::DataType
    JCostsI::DataType
    JCosts::DataType
    JCostsBuilder::DataType
    FleetSize::DataType
    JVrp::DataType
    JVrpBuilder::DataType
    JAlgorithm::DataType
    JSP::DataType
    JSPBuilder::DataType
    JSolution::DataType
    JSolutions::DataType
    JVehicleRoute::DataType
    JTourActivity::DataType
    JJobActivity::DataType
    JStartActivity::DataType
    JEndActivity::DataType
    JCollection::DataType
    JList::DataType
    JMap::DataType
    function JspritJavaTypes()
        jcoord = JavaCall.@jimport com.graphhopper.jsprit.core.util.Coordinate
        jlocation = JavaCall.@jimport com.graphhopper.jsprit.core.problem.Location
        jlocationbuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.Location$Builder
        jtw = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.route.activity.TimeWindow
        jabsjob = JavaCall.@jimport com.graphhopper.jsprit.core.problem.AbstractJob
        jjob = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Job
        jpickup = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Pickup
        jpickupbuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Pickup$Builder
        jdelivery = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Delivery
        jdeliverybuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Delivery$Builder
        jshipment = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Shipment
        jshipmentbuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Shipment$Builder
        jservice = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Service
        jservicebuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.job.Service$Builder
        jvtypei = JavaCall.@jimport com.graphhopper.jsprit.core.problem.vehicle.VehicleType
        jvtypeimpl = JavaCall.@jimport com.graphhopper.jsprit.core.problem.vehicle.VehicleTypeImpl
        jvtypebuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.vehicle.VehicleTypeImpl$Builder 
        jabsvehicle = JavaCall.@jimport com.graphhopper.jsprit.core.problem.AbstractVehicle
        jvehiclei = JavaCall.@jimport com.graphhopper.jsprit.core.problem.vehicle.Vehicle
        jvehicleimpl = JavaCall.@jimport com.graphhopper.jsprit.core.problem.vehicle.VehicleImpl
        jvehiclebuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.vehicle.VehicleImpl$Builder
        jcostsi = JavaCall.@jimport com.graphhopper.jsprit.core.problem.cost.VehicleRoutingTransportCosts
        jcosts = JavaCall.@jimport com.graphhopper.jsprit.core.util.TimeDependentVehicleRoutingTransportCosts
        jcostsbuilder = JavaCall.@jimport com.graphhopper.jsprit.core.util.TimeDependentVehicleRoutingTransportCosts$Builder
        fleetsize = JavaCall.@jimport com.graphhopper.jsprit.core.problem.VehicleRoutingProblem$FleetSize
        jvrp = JavaCall.@jimport com.graphhopper.jsprit.core.problem.VehicleRoutingProblem
        jvrpbuilder = JavaCall.@jimport com.graphhopper.jsprit.core.problem.VehicleRoutingProblem$Builder
        jalgorithm = JavaCall.@jimport com.graphhopper.jsprit.core.algorithm.VehicleRoutingAlgorithm
        jsp = JavaCall.@jimport com.graphhopper.jsprit.core.algorithm.box.Jsprit
        jspbuilder = JavaCall.@jimport com.graphhopper.jsprit.core.algorithm.box.Jsprit$Builder
        jsolution = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.VehicleRoutingProblemSolution
        jsolutions = JavaCall.@jimport com.graphhopper.jsprit.core.util.Solutions
        jvehicleroute = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.route.VehicleRoute
        jtouractivity = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.route.activity.TourActivity
        jjobactivity = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.route.activity.TourActivity$JobActivity
        jstartactivity = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.route.activity.Start
        jendactivity = JavaCall.@jimport com.graphhopper.jsprit.core.problem.solution.route.activity.End
        jcollection = JavaCall.@jimport java.util.Collection
        jlist = JavaCall.@jimport java.util.List
        jmap = JavaCall.@jimport java.util.Map
        new(
            jcoord,
            jlocation,
            jlocationbuilder,
            jtw,
            jabsjob,
            jjob,
            jpickup,
            jpickupbuilder,
            jdelivery,
            jdeliverybuilder,
            jshipment,
            jshipmentbuilder,
            jservice,
            jservicebuilder,
            jvtypei,
            jvtypeimpl,
            jvtypebuilder,
            jabsvehicle,
            jvehiclei,
            jvehicleimpl,
            jvehiclebuilder,
            jcostsi,
            jcosts,
            jcostsbuilder,
            fleetsize,
            jvrp,
            jvrpbuilder,
            jalgorithm,
            jsp,
            jspbuilder,
            jsolution,
            jsolutions,
            jvehicleroute,
            jtouractivity,
            jjobactivity,
            jstartactivity,
            jendactivity,
            jcollection,
            jlist,
            jmap
        )
    end
end

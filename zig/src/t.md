Found a node on the left with a shape:          
shapes.Shape{ 
    .bvhNode = shapes.BvhNode{ 
        .left = shapes.Shape{ 
            .bvhNode =  }, 
        .right = shapes.Shape{ 
            .sphere = shapes.Sphere{ ... } }, 
        .box = boundingBox.BoundingBox{ 
            .min = { -1.1128807137978754e+01, 0.0e+00, -1.1183039297919876e+01 }, 
            .max = { 1.1098062869337257e+01, 8.995299179509784e-01, 1.1054045630282378e+01 } } } }                                                                                                                                                      
Found a node on the right with shape: 

shapes.Shape{ 
    .bvhNode = shapes.BvhNode{ 
        .left = shapes.Shape{ 
            .bvhNode =  }, 
        .right = shapes.Shape{ 
            .sphere = shapes.Sphere{ ... } }, 
        .box = boundingBox.BoundingBox{ 
            .min = { -1.1128807137978754e+01, 0.0e+00, -1.1183039297919876e+01 }, 
            .max = { 1.1098062869337257e+01, 8.995299179509784e-01, 1.1054045630282378e+01 } } } }

shapes.Shape{ 
    .sphere = shapes.Sphere{ 
        .center = { 0.0e+00, -1.0e+03, 0.0e+00 }, 
        .radius = 1.0e+03, 
        .material = materials.Material{ 
            .lambertian = materials.Lambertian{ ... } } } }    

shapes.Shape{ 
    .sphere = shapes.Sphere{ 
        .center = { -4.0e+00, 1.0e+00, 0.0e+00 }, 
        .radius = 1.0e+00, 
        .material = materials.Material{ 
            .lambertian = materials.Lambertian{ ... } } } } 

shapes.Shape{ 
    .sphere = shapes.Sphere{ 
        .center = { 0.0e+00, 1.0e+00, 0.0e+00 }, 
        .radius = 1.0e+00, 
        .material = materials.Material{ 
            .dialectric = materials.Dialectric{ ... } } } }   

shapes.Shape{ 
    .sphere = shapes.Sphere{ 
        .center = { 4.0e+00, 1.0e+00, 0.0e+00 }, 
        .radius = 1.0e+00, 
        .material = materials.Material{ 
            .metal = materials.Metal{ ... } } } }
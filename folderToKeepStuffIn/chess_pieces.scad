echo(version=version());
//*
// pawn
color("green"){
    rotate_extrude($fn = 80)
        polygon(points=[
            [0,0],[0.5, 0],[0.5,2],
            [3,2],[3,4],[1,6],
            [2, 7], [1, 7.5], [0, 7.5]
        ] );
    translate([0, 0, 8.8])
        sphere(1.5);
}
//*/
        
        
// rook
color("red")
translate([15, 0, 0])
scale([1.2, 1.2, 1]){
    rotate_extrude($fn = 80)
        polygon(points=[
            [0,0],[0.5, 0],[0.5,2],
            [3,2],[3,4],[1,5.5],
            [2, 7], [1.5, 7.5], [2, 8.0], [2, 9.0], [0, 9.0]
        ] );
        //translate([0, 0, 8.8])
          //  sphere(1.5);
    for (i = [0:60:359])
        echo(i)
        rotate(i, [0, 0, 1]){
            translate([1.75, 0, 9.25])
                cube([0.5, 0.5, 0.5], center=true);
        }
}
        
        

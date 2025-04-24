echo(version=version());
//*
$fn = 80;
// pawn
translate([15, 15, 0]) color("green"){
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,0],[1.0, 0],[1.0,2], // peg
                [3,2],[3,4], // flat base
                [2, 9], // cone
		[1, 9.5], [0, 9.5] // end
            ] );
        translate([0, 0, 7]) rotate_extrude() translate([6, 0, 3]) circle(4);
    }
    translate([0, 0, 10.8])
        sphere(2.0);
}
//*/
        
        
//*
// rook
color("red")
translate([15, 0, 0])
union() {
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,0],[1.0, 0],[1.0,2], // peg
                [3,2],[3,4], // flat base
                [2, 9], // cone
		//[1, 7.5], [0, 7.5] // end
		[2, 10.0], [2, 10.0], [0, 10.0] // head
            ] );
        translate([0, 0, 7]) rotate_extrude() translate([6, 0, 3]) circle(4);
    }
    for (i = [0:60:359])
        rotate(i, [0, 0, 1]){
            translate([1.60, 0, 10.4])
                cube(0.8, center=true);
        }
}
        
        
// bishop
color("blue")
translate([0, 15, 0])
union () {
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,0],[1.0, 0],[1.0,2], // peg
                [3,2],[3,4], // flat base
                [2, 9], // cone
		//[1, 7.5], [0, 7.5] // end
		[1, 10.0], [0, 10.0] // head
            ] );
        translate([0, 0, 7]) rotate_extrude() translate([6, 0, 3]) circle(4);
    }
    translate([0, 0, 0.7]) union() {
    difference() {
	    translate([0, 0, 10]) rotate_extrude()
		    intersection() {
			    scale([1, 0.6]) circle(2.5);
			    translate([0, -5]) square(10);
		    };
	    translate([1.2, 0, 11.0]) cube([0.5, 5, 1.4], center=true);
    }
	    translate([0, 0, 11.5]) rotate_extrude()
		    intersection() {
			    scale([1, 0.6]) circle(1.0);
			    translate([0, -5]) square(10);
		    };
    }
}

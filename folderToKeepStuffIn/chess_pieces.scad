echo(version=version());
//*
$fn = 80;
// pawn
translate([15, 15, 0]) color("green"){
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,0],[0.5, 0],[0.5,2], // peg
                [3,2],[3,4], // flat base
                [2, 7], // cone
		[1, 7.5], [0, 7.5] // end
            ] );
        translate([0, 0, 6]) rotate_extrude() translate([5, 0, 3]) circle(3);
    }
    translate([0, 0, 8.8])
        sphere(2.0);
}
//*/
        
        
//*
// rook
color("red")
translate([15, 0, 0])
scale([1.2, 1.2, 1]){
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,0],[0.5, 0],[0.5,2], // peg
                [3,2],[3,4], // flat base
                [2, 7], // cone
		//[1, 7.5], [0, 7.5] // end
		[2, 8.0], [2, 8.0], [0, 8.0] // head
            ] );
        translate([0, 0, 6]) rotate_extrude() translate([5, 0, 3]) circle(3);
    }
    for (i = [0:60:359])
        rotate(i, [0, 0, 1]){
            translate([1.75, 0, 8.25])
                cube([0.5, 0.5, 0.5], center=true);
        }
}
        
        
// bishop
color("blue")
translate([0, 15, 0])
scale([1.2, 1.2, 1]){
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,0],[0.5, 0],[0.5,2], // peg
                [3,2],[3,4], // flat base
                [2, 7], // cone
		//[1, 7.5], [0, 7.5] // end
		[2, 8.0], [2, 8.0], [0, 8.0] // head
            ] );
        translate([0, 0, 6]) rotate_extrude() translate([5, 0, 3]) circle(3);
    }
    difference() {
	    translate([0, 0, 8]) rotate_extrude()
		    intersection() {
			    scale([1, 0.6]) circle(2.5);
			    translate([0, -5]) square(10);
		    };
	    translate([1.2, 0, 9.0]) cube([0.5, 5, 1.4], center=true);
    }
	    translate([0, 0, 9.5]) rotate_extrude()
		    intersection() {
			    scale([1, 0.6]) circle(1.0);
			    translate([0, -5]) square(10);
		    };
}

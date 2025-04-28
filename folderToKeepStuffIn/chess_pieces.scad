echo(version=version());
//*
$fn = 80;
// pawn
translate([15, 15, 0]) color("green"){
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,-3],[1.5, -3],[1.5,2], // peg
                [4,2],[4,6], // flat base
                [2, 10.0], // cone
		[1, 10.5], [0, 10.5] // end
            ] );
        translate([0, 0, 8]) rotate_extrude() translate([6, 0, 3]) circle(4);
    }
    translate([0, 0, 12.8])
        sphere(3.0);
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
                [0,-3],[1.5, -3],[1.5,2], // peg
                [4,2],[4,6], // flat base
                [3.5, 9], // cone
		//[1, 7.5], [0, 7.5] // end
		[3.5, 12.0], [0, 12.0] // head
            ] );
        translate([0, 0, 8]) rotate_extrude() translate([6, 0, 3]) circle(4);
    }
        rotate_extrude($fn = 80)
            polygon(points=[
		[0, 11.0], [3.5, 11.0],
		[3.5, 13.0], [0, 13.0] // head
            ] );
    for (i = [0:60:359])
        rotate(i, [0, 0, 1]){
            translate([3.0, 0, 13.4])
                cube([1, 1.25, 1], center=true);
        }
}
        
        
// bishop
color("blue")
translate([0, 15, 0])
union () {
    difference() {
        rotate_extrude($fn = 80)
            polygon(points=[
                [0,-3],[1.5, -3],[1.5,2], // peg
                [4,2],[4,6], // flat base
                [3.5, 9], // cone
		//[1, 7.5], [0, 7.5] // end
		[1, 10.5], [0, 10.5] // head
            ] );
        translate([0, 0, 8]) rotate_extrude() translate([6, 0, 3]) circle(4);
    }
    translate([0, 0, 0.7]) union() {
    difference() {
	    translate([0, 0, 11]) rotate_extrude()
		    intersection() {
			    scale([1, 0.6]) circle(3.5);
			    translate([0, -5]) square(10);
		    };
	    translate([1.5, 0, 12.5]) cube([0.75, 7, 1.6], center=true);
    }
	    translate([0, 0, 13.5]) rotate_extrude()
		    intersection() {
			    scale([1, 0.6]) circle(1.3);
			    translate([0, -5]) square(10);
		    };
    }
}

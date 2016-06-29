/*

Copyright (c) 2016, Colin Wass, CFTech.ca
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that
the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the
following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

*/

/*
You need to create the appropriate namespacce.
*/

use template1;

CREATE TABLE `d01users` (
  `userid` int NOT NULL AUTO_INCREMENT,
  `username` TEXT NOT NULL,
  `password` TEXT NOT NULL,
  `createdate` date NOT NULL,
  `terminatedate` date DEFAULT NULL,
  `email` TEXT NOT NULL,
  `lasttouch` int NOT NULL,
  `l01userauthorities_authorityid` int NOT NULL,
  PRIMARY KEY (`userid`),
  KEY `fk_d01users_l01userauthorities_idx` (`l01userauthorities_authorityid`),
  CONSTRAINT `fk_d01users_l01userauthorities` FOREIGN KEY (`l01userauthorities_authorityid`) REFERENCES `l01userauthorities` (`authorityid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `l01userauthorities` (
  `authorityid` int NOT NULL AUTO_INCREMENT,
  `authoritylabel` varchar(100) NOT NULL,
  PRIMARY KEY (`authorityid`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;


CREATE TABLE `sessions` (
  `id` char(32) NOT NULL,
  `a_session` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create or replace view
`v01credentials` as
select `d01`.`userid` as `userid`,
	`d01`.`username` as `screenname`,
    `d01`.`createdate` as `createdate`,
    `d01`.`email` as `email`,
    `d01`.`terminatedate` as `terminatedate`,
    `d01`.`password` AS `password`,
    `d01`.`l01userauthorities_authorityid`,
    `l01`.`authoritylabel` as `authoritylabel`
from `d01users` `d01`, `l01userauthorities` `l01`
where `d01`.`l01userauthorities_authorityid` = `l01`.`authorityid`;

DELIMITER $$
CREATE 
PROCEDURE `template1`.`P01Adduser`(IN NewUserName TEXT, IN NewPassword TEXT, IN NewEmail TEXT, IN NewAuthorityId INT)
BEGIN


insert into d01users(username, password, createdate, email, l01userauthorities_authorityid, lasttouch)
values
(NewUserName, NewPassword, NewEmail, NewAuthorityId, 1);

END$$
DELIMITER ;

/*
Create a simple data table for the user data and a lookup table for authorities.
This is there to demonstrate a simple method for using lookup tables in a system as
intended with these templates.  The actual work, the little bit required, actually
happens in the views.

The sample view simply pulls the user data and provides the text label for the authority.
From the perl script/library, it is treated exactly as a table.  See the discussion
article on cftech.ca for details and why you should do this.

The sample stored procedure expects to be called with a username, password, email and 
authority id (which is an integer that has an entry in l01userauthorities).

See lib/libtemplate1.pm and the discussion article on cftech.ca for an example of 
how to access a stored procedure from a perl script.

*/


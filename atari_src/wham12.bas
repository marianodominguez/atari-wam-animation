   pq���AD�RDG�RDS�RUG�RUS�LDG�LDS�LUG�LUS�FILE�DAT�CL�F��ML�ML���BAC�B�B����S�S�BAS�DL�SC1�SC1�DL�SC2�SC2�D�DP�DP��BG�� @       �      �      �      �      �      �      �      �      �	      ��      �      �                                                                                                                                                    !       "       #       $      �%       &      �  WHAM12.BAS  10/09
 "" USES FRAME12.BIN AND VERS.12
  LINE ROUTINES
( �9@    ,2 �;@Y    ,�;@Y    ,< �;@Y    ,�;@Y    ,F �;@d    ,�;@d    ,P �;@d    ,�;@d    ,Z �;@     ,�;BP  ,d �;@    ,�;@    ,n  
x  RIGHT,DOWN,GENTLE
� EE6�.;�Ъ�J�Ϡ ��ܑܥ�eх�8�А����i�ܐ��fېf���������l? � 6�8      ,-C:�,�  
�  RIGHT,DOWN,STEEP
� EE6�.;�Ѫ�J�Ϡ ��ܑܥ�eЅ�8�ѐ��fېf��������i�ܐ�����l? � 6�8@    ,-C:�,�  
�  RIGHT,UP,GENTLE
� EE6�.;�Ъ�J�Ϡ ��ܑܥ�eх�8�А��8����ܰ��fېf���������l? � 6�8@    ,-C:�,�  
�  RIGHT,UP,STEEP
� EE6�.;�Ѫ�J�Ϡ ��ܑܥ�eЅ�8�ѐ��fېf������8����ܰ�����l? 6�8@    ,-C:�, 
 LEFT,DOWN,GENTLE
"JJ6�.@�Ъ�J�Ϡ ��ܑܥ�eх�8�А����i�ܐ��&ې&ۥ�8��ܰ�����l? ,6�8@    ,-C:�,6 
@ LEFT,DOWN,STEEP
JJJ6�.@�Ѫ�J�Ϡ ��ܑܥ�eЅ�8�ѐ��&ې&�8����ܰ����i�ܐ�����l? T6�8@    ,-C:�,^ 
h LEFT,UP,GENTLE
rJJ6�.@�Ъ�J�Ϡ ��ܑܥ�eх�8�А��8����ܰ��&ې&�8����ܰ�����l? |6�8@    ,-C:�,� 
� LEFT,UP,STEEP
�JJ6�.@�Ѫ�J�Ϡ ��ܑܥ�eЅ�8�ѐ��&ې&�8����ܰ��8����ܰ�����l? �6�8@    ,-C:�,� 
�"" SET UP ADDRESS TABLE AT $6E8
��-      @    �6�-P:�8�,'AV   ,�6�-�8�,&�$AV   �Ah   %�$@    ��Ai   %�$@    ��	�� 
 SET UP Z-TABLE AT $6F8
6�-A(   �-      @    &A�   %��06�-�'@    :	�D## PLACE THE CASE ROUTINE RETURN
N## ADDRESS INTO "BACK" ($3F,$40)
X THAT ADDRESS IS NOW $6DC
b6�-AV   l&6�-P:�'AV   ,&6�-�&+�$AV   ,v@c    �@d    �� 
�ZD1:FRAME.BIN�&&(DIRECTORY OF ATARI WHAM MOVIES�(             (AWM)�(�HD1:*.AWM�(�--(%TYPE THE NAME OF A MOVIE FILE TO PLAY�++(#  (IT'S NOT NECESSARY TO TYPE .AWM)� �(((     WHEN FINISHED, PRESS <BREAK>�''(     TO SELECT ANOTHER, PRESS R�( FILE�6�.D1:6�7@    ,.�!!X:�<.AWM,      A    6�7B:�,%@    ,..AWM*$ (DARK BACKGROUND(Y OR N)$�4(JIFFIES PER FRAME�> LOADING DATA...HZ�R  @    @          �\)@    �)@    �f)@    �)@    �p6�-�$AV   %�z@    � 
� SET UP 2 SCREENS
�+@"    �%%6
-F:A`   ,%F:Aa   ,$AV   �6�-F:
%@    ,�6�-F:
%@    ,�  A   F:A   ,&@    �+@"    �%%6�-F:A`   ,%F:Aa   ,$AV   �6�-F:�%@    ,�6�-F:�%@    ,� SET EXTEND BYTE TO ZERO
�A0         �@    �4Y)�4YESA`   70                  70@          @    �Ap   $70            @    70@                .$$ POKE DATA PTR INTO $E9 AND $EA
8		6�-�B&6�-P:�'AV   ,&6�-�&+�$AV   ,LA1   �A2   �VA3   �A4   �` 
j ANIMATION LOOP
t 
~ 
� SCREEN 1
�@           �@�    �@�    �� ERASE & DRAW FRAME
�6�-?:A6   ,��� SHOW
��%@    ��%@    ��--F:@     , �%@    $F:A0   ,A0   �A0         � 
� SCREEN 2
�@           �@�    �@�    �  ERASE & DRAW FRAME
�6�-?:A6   ,�� SHOW
�%@    ��%@    �(--F:@     , �%@    $F:A0   ,A    -A0         2 
<�A0    �D1:WHAM12.BAS
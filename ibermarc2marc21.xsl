<?xml version="1.0" encoding="UTF-8"?>
<!--Ibermarc2marc21.xsl  se distribuye bajo Licencia con arreglo a la EUPL, Versión 1.1 o –en cuanto sean aprobadas por la Comisión Europea– versiones posteriores de la EUPL (la «Licencia»); Solo podrá usarse esta obra si se respeta la Licencia. Puede obtenerse una copia de la Licencia en:  http://ec.europa.eu/idabc/servlets/Docb4f4.pdf?id=31980
Salvo cuando lo exija la legislación aplicable o se acuerde por escrito, el programa distribuido con arreglo a la Licencia se distribuye «TAL CUAL», SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ni expresas ni implícitas.
Véase la Licencia en el idioma concreto que rige los permisos y limitaciones que establece la Licencia-->

<!--Ibermarc2marc21.xsl  (revisión 0.9)  20101209 -->
<!--Ibermarc2marc21.xsl  (revisión 1)  20111011 incluye comentarios en las equivalencias -->
<!--Ibermarc2marc21.xsl  (revisión 1.1)  20111103 corrige error detectado en línea 968 y sig. -->

<!--hoja de transformación para convertir IBERMARC A MARC21slim-->

<xsl:stylesheet version="1.0" xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/ standards/marcxml/schema/MARC21slim.xsd" exclude-result-prefixes="marc" >

    <xsl:include href="http://www.loc.gov/marcxml/xslt/MARC21slimUtils.xsl"/>
    <!--<xsl:include href="./MARC21slimUtils.xsl"/>-->

    <xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8"/>

    <!-- Valores válidos para los indicadores -->
    <xsl:variable name="valoresind"><xsl:text>abcdefghijklmnopqrstuvwxyz0123456789 </xsl:text></xsl:variable>

    <!-- función que copia subcampos determinados (acordes al conjunto de subcampos válidos) tal cual -->
    <xsl:template name="subfieldSelectAll">
        <xsl:param name="codes">abcdefghijklmnopqrstuvwxyz0123456789</xsl:param>
        <xsl:for-each select="marc:subfield">
            <xsl:if test="contains($codes, @code)">
                <xsl:copy>
                    <xsl:copy-of select="@*" />
                    <xsl:apply-templates />
                </xsl:copy>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- función para crear subcampos cada 3 caracteres en el campo 41 -->
    <xsl:template name="subfield41">
        <xsl:param name="str"/>
        <xsl:param name="code"/>
        <xsl:if test="$str">
            <xsl:variable name="str2">
                <xsl:call-template name="chopPunctuationFront">
                    <xsl:with-param name="chopString" select="$str"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:copy>
                <xsl:attribute name="code"><xsl:value-of select="$code"/></xsl:attribute>
                <xsl:value-of select="substring($str2,1,3)"/>
            </xsl:copy>
            <xsl:if test="string-length($str2) &gt; 3">
                <xsl:call-template name="url-encode">
                    <xsl:with-param name="str" select="substring($str2,4)"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- Procesar nodo raíz -->
    <xsl:template match="/">
        <xsl:if test="marc:collection">
            <xsl:apply-templates select="marc:collection"/>
        </xsl:if>
        <xsl:if test="marc:record">
            <xsl:apply-templates select="marc:record"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Sólo funciona con libxml2 -->
    <!--<xsl:attribute-set name="registro_att">
        <xsl:attribute name="xmlns"><xsl:text>http://www.loc.gov/MARC21/slim</xsl:text></xsl:attribute>
        <xsl:attribute name="xmlns:xsi" namespace="http://www.w3.org/2001/XMLSchema-instance">http://www.w3.org/2001/XMLSchema-instance</xsl:attribute>
        <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/MARC21/slim http://www.loc.gov/ standards/marcxml/schema/MARC21slim.xsd</xsl:attribute>
    </xsl:attribute-set>-->

    <!-- procesar collection -->
    <xsl:template match="marc:collection">
        <!--<xsl:copy use-attribute-sets="registro_att">-->
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <!-- procesar registro MARC -->
    <xsl:template match="marc:record">
        <!--<xsl:copy use-attribute-sets="registro_att">-->
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <!-- procesar cabecera MARC, se mapea igual excepto:
        - pos 7: se cambia '-' por la 'i'
        - pos 9: se cambia: '7' o '8' o 'z' por un espacio en blanco
        - pos 18: se cambia: 'b' por un espacio en blanco
        - pos 19: se cambia: 'r' por un espacio en blanco
    -->
    <xsl:template match="marc:leader">
        <xsl:copy>
            <xsl:value-of select="substring(text(),1,5)" />
            <xsl:value-of select="substring(text(),6,1)" />
            <xsl:value-of select="substring(text(),7,1)" />
            <xsl:variable name="leader7" select="substring(.,8,1)"/>
            <xsl:choose>
                <xsl:when test="$leader7='-' or $leader7=' '">i</xsl:when>
                <xsl:otherwise><xsl:value-of select="$leader7" /></xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="substring(text(),9,1)" />
            <xsl:variable name="leader9" select="substring(.,10,1)"/>
            <xsl:choose>
                <xsl:when test="$leader9='7' or $leader9='8' or $leader9='z'"><xsl:text> </xsl:text></xsl:when>
                <xsl:otherwise><xsl:value-of select="$leader9" /></xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="substring(text(),11,1)" />
            <xsl:value-of select="substring(text(),12,1)" />
            <xsl:value-of select="substring(text(),13,5)" />
            <xsl:value-of select="substring(text(),18,1)" />
            <xsl:variable name="leader18" select="substring(.,19,1)"/>
            <xsl:choose>
                <xsl:when test="$leader18='b'"><xsl:text> </xsl:text></xsl:when>
                <xsl:when test="$leader18=' '"><xsl:text>c</xsl:text></xsl:when>
                <xsl:otherwise><xsl:value-of select="$leader18" /></xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="leader19" select="substring(.,20,1)"/>
            <xsl:choose>
                <xsl:when test="$leader19='r'"><xsl:text> </xsl:text></xsl:when>
                <xsl:otherwise><xsl:value-of select="$leader19" /></xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="substring(text(),21,4)" />
        </xsl:copy>
    </xsl:template>


    <!-- procesar campos de control, se mapean sin cambios -->
    <xsl:template match="marc:controlfield">
        <xsl:copy-of select="." />
    </xsl:template>


    <!-- procesar campo variable 010, se mapea igual al campo 016:
        - si el indicador1 es un espacio se mapea al valor 7 y con subcampo $2 con valor BNE
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
    -->
    <xsl:template match="marc:datafield[@tag='010']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:attribute name="tag"><xsl:text>016</xsl:text></xsl:attribute>
            <xsl:if test="@ind1='#'">
                <xsl:attribute name="ind1">7</xsl:attribute>
                <marc:subfield code="2">BNE</marc:subfield>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 019, se mapea igual al campo 017:
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='019']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:attribute name="tag"><xsl:text>017</xsl:text></xsl:attribute>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">a68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 021, se mapea igual al campo 026:
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - el subcampo $a se mapea al $e
        - los subcampos $2 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='021']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:attribute name="tag"><xsl:text>026</xsl:text></xsl:attribute>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="@ind2='7' or not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains('a', @code)">
                    <marc:subfield code="e">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">2568</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 026, se mapea igual al campo 024:
        - si el indicador1 es un # se mapea al valor 8
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='026']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:attribute name="tag"><xsl:text>024</xsl:text></xsl:attribute>
            <xsl:if test="@ind1='#'">
                <xsl:attribute name="ind1">8</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">a68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 029, se mapea igual al campo 024:
        - si el indicador1 es un 0 ó 1 se mapea al valor espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $z $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='029']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:attribute name="tag"><xsl:text>024</xsl:text></xsl:attribute>
            <xsl:if test="@ind1='0' or @ind1='1' or not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">az68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 033
        - si el indicador1 es un 2 se mapea al valor 4
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
    -->
    <xsl:template match="marc:datafield[@tag='033']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="@ind1='2'">
                <xsl:attribute name="ind1">4</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 041
        - si el indicador2 es un # se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - para los subcampos $a $b cada tres caracteres que estén en IBERMARC se añadirá un nuevo subcampo ya que este campo en el MARC 21 sí es repetible
        - los subcampos $d $e $f $g $h $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='041']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="@ind2='#' or not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains('ab', @code)">
                    <xsl:call-template name="subfield41">
                        <xsl:with-param name="str" select="text()"/>
                        <xsl:with-param name="code" select="@code"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">defgh68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 044
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - el subcampos $c se mapea al subcampo $b
        - los subcampos $a $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='044']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='c'">
                    <marc:subfield code="b">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">a68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 100
        - si el indicador1 es un 3 se mapea por un 2
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $k $l $n $p $q $t $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='100']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="@ind1='3'">
                <xsl:attribute name="ind1">2</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefgklnpqtu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 110
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $k $l $n $p $q $t $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='110']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefgklnpqtu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 111
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $c $d $e $f $g $k $l $n $p $q $t $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='111']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">acdefgklnpqtu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 130
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $d $f $g $h $k $l $m $n $o $p $r $s $t $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='130']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">adfghklmnoprst68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 260
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $e $f $g $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='260']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcefg68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 505
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $g $r $t $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='505']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">agrtu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 506
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $3 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='506']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcde3568</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 511
        - si el indicador1 es un 2 ó 3 se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='511']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="@ind1='2' or @ind1='3' or not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">a68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 514
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $i $j $k $m $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='514']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghijkmu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 520
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $u $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='520']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abu368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 530
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $u $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='530']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdu368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 545
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='545']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 552
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $u $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='552']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghijklmnopu68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 555
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $u $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='555']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdu368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 600 ó 610 ó 611 ó 630
        - si el indicador2 es un 1 ó 8 se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $j se mapean por subcampos $v
        - los subcampos $a $b $c $d $e $f $g $h $k $l $m $n $o $p $q $r $s $t $u $x $y $z $2 $3 $4 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='600' or @tag='610' or @tag='611' or @tag='630']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="@ind2='1' or @ind2='8' or not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='j'">
                    <marc:subfield code="v">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghklmnopqrstuxyz23468</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 650
        - si el indicador2 es un 1 ó 8 se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $j se mapean por subcampos $v
        - los subcampos $a $c $d $x $y $z $2 $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='650']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="@ind2='1' or @ind2='8' or not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='j'">
                    <marc:subfield code="v">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">acdxyz2368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 651
        - si el indicador2 es un 1 ó 8 se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $j se mapean por subcampos $v
        - los subcampos $a $x $y $z $2 $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='651']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="@ind2='1' or @ind2='8' or not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='j'">
                    <marc:subfield code="v">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">axyz2368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 653
        - si el indicador1 es un 1 ó 2 ó 3 ó # se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $j se mapean por subcampos $v
        - los subcampos $a $x $y $z $2 $3 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='653']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">a68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 655
        - si el indicador1 es un 1 ó 2 ó 3 ó # se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $j se mapean por subcampos $v
        - los subcampos $a $x $y $z $2 $3 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='655']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="@ind1='1' or @ind1='2' or @ind1='3' or @ind1='#' or not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='j'">
                    <marc:subfield code="v">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">axyz23568</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 656
        - si el indicador2 es un 4 se mapea por un espacio
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $j se mapean por subcampos $v
        - los subcampos $a $x $y $z $2 $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='656']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="@ind2='4' or not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='j'">
                    <marc:subfield code="v">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">axyz2368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 700
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $k $l $m $n $o $p $q $r $s $t $u $x $3 $4 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='700']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghklmnopqrstux34568</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 710
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $k $l $m $n $o $p $r $s $t $u $x $3 $4 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='710']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghklmnoprstux34568</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 711
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $k $l $n $p $s $t $u $x $3 $4 $5 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='711']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghklnpstux34568</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 752
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='752']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcd68</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 800
        - si el indicador1 es un 3 se mapea por un 2
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $k $l $m $n $o $p $q $r $s $t $u $v $4 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='800']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="@ind1='3'">
                <xsl:attribute name="ind1">2</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghklmnopqrstuv468</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 810
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $b $c $d $e $f $g $h $k $l $m $n $o $p $r $s $t $u $v $4 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='810']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcdefghklmnoprstuv468</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 811
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $a $c $d $e $f $g $h $k $l $n $o $p $s $t $u $v $4 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='811']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">acdefghklnopstuv468</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- procesar campo variable 852
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
        - los subcampos $o se mapean por subcampos $d
        - los subcampos $a $b $c $e $f $g $h $i $j $k $l $m $n $p $q $s $t $x $z $2 $3 $6 $8 se mapean igual, el resto de descartan
    -->
    <xsl:template match="marc:datafield[@tag='852']">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="@ind1='9' or not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="@code='o'">
                    <marc:subfield code="d">
                        <xsl:value-of select="text()"/>
                    </marc:subfield>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="subfieldSelectAll">
                <xsl:with-param name="codes">abcefghijklmnpqstxz2368</xsl:with-param>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>


    <!-- el resto de campos variables se mapean tal cual excepto:
        - si los indicadores no contienen valores válidos se mapean por un espacio en blanco
    -->
    <xsl:template match="marc:datafield">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:if test="not(contains($valoresind,@ind1))">
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:if test="not(contains($valoresind,@ind2))">
                <xsl:attribute name="ind2"><xsl:text> </xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="marc:subfield">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="*">
        <xsl:message>unhandled XML element: <xsl:value-of select="name(.)" /></xsl:message>
    </xsl:template>

</xsl:stylesheet>
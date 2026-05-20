--ヴァレット・コーダー
--not fully implemented
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：把这张卡在「枪管」怪兽的连接召唤使用的场合，可以把这张卡的种族当作龙族使用。
-- ③：把自己场上的这张卡作为「枪管」怪兽的连接素材的场合，手卡的暗属性怪兽也能有最多1只作为连接素材。
local s,id,o=GetID()
-- 在初始化函数中注册该卡片的三个效果：①手卡作为「码语者」连接素材的效果，②作为「枪管」连接素材时当作龙族的效果，③场上的这张卡作为「枪管」连接素材时手卡暗属性怪兽也能作为连接素材的效果。
function s.initial_effect(c)
	-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval1)
	c:RegisterEffect(e1)
	-- ②：把这张卡在「枪管」怪兽的连接召唤使用的场合，可以把这张卡的种族当作龙族使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(id)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- ③：把自己场上的这张卡作为「枪管」怪兽的连接素材的场合，手卡的暗属性怪兽也能有最多1只作为连接素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	-- 设置e3效果的适用对象为手牌中的暗属性怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK))
	e3:SetCountLimit(1,id+o)
	e3:SetValue(s.matval2)
	c:RegisterEffect(e3)
end
-- 过滤条件：位于自己场上的电子界族怪兽。
function s.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 过滤条件：位于手牌中的同名卡（弹丸编码员）。
function s.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(id)
end
-- e1效果的Value函数，限制连接怪兽必须是「码语者」怪兽，且连接素材中必须包含自己场上的电子界族怪兽，同时不能包含其他手牌中的同名卡。
function s.matval1(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(s.mfilter,1,nil,tp) and not mg:IsExists(s.exmfilter,1,nil)
end
-- 检查手牌中的怪兽是否受到其他允许作为额外连接素材的效果影响，用于防止与其他手牌连接素材效果叠加使用。
function s.exmatcheck(c,lc,tp)
	if not c:IsLocation(LOCATION_HAND) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		local related,valid=f(te,lc,nil,c,tp)
		if related and not te:GetHandler():IsCode(id) then return false end
	end
	return true
end
-- e3效果的Value函数，限制连接怪兽必须是「枪管」怪兽，且连接素材中必须包含场上的这张卡，同时不能包含其他通过其他效果作为额外素材的手牌怪兽。
function s.matval2(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x10f) then return false,nil end
	return true,not mg or mg:IsContains(e:GetHandler()) and not mg:IsExists(s.exmatcheck,1,nil,lc,tp)
end

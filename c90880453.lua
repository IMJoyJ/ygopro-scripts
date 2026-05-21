--エルフェンノーツ～再邂のテルチェット～
-- 效果：
-- ①：对方不能把自己的中央的主要怪兽区域的怪兽作为效果的对象。
-- ②：自己的中央的主要怪兽区域的怪兽属性让这张卡得到以下效果。
-- ●炎·地：自己的同调怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ●水·风：自己场上的其他的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
-- ●光·暗：自己受到的战斗伤害变成0。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果（发动、不能成为效果对象、贯穿、魔陷破坏抗性、战斗伤害变0）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能把自己的中央的主要怪兽区域的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tglimit)
	-- 设置不能成为效果对象效果的过滤函数，使其仅对对方的效果生效。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ●炎·地：自己的同调怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.piercecon)
	e3:SetTarget(s.piercetg)
	c:RegisterEffect(e3)
	-- ●水·风：自己场上的其他的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetCondition(s.indcon)
	e4:SetTarget(s.indtg)
	-- 设置不会被效果破坏效果的过滤函数，使其仅对对方的效果生效。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ●光·暗：自己受到的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.abdcon)
	c:RegisterEffect(e5)
end
-- 过滤自身场上中央主要怪兽区域（格子编号为2）的怪兽。
function s.tglimit(e,c)
	return c:GetSequence()==2
end
-- 过滤自身场上中央主要怪兽区域表侧表示的地属性或炎属性怪兽。
function s.piercefilter(c)
	return c:GetSequence()==2 and c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE)
		and c:IsFaceup()
end
-- 贯穿效果的发动条件：自身场上中央主要怪兽区域存在表侧表示的地属性或炎属性怪兽。
function s.piercecon(e)
	-- 检查自身场上是否存在满足条件的中央主要怪兽区域的地·炎属性怪兽。
	return Duel.IsExistingMatchingCard(s.piercefilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤受到贯穿效果影响的怪兽，限定为同调怪兽。
function s.piercetg(e,c)
	return c:IsType(TYPE_SYNCHRO)
end
-- 过滤自身场上中央主要怪兽区域表侧表示的水属性或风属性怪兽。
function s.indfilter(c)
	return c:GetSequence()==2 and c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_WIND)
		and c:IsFaceup()
end
-- 破坏抗性效果的发动条件：自身场上中央主要怪兽区域存在表侧表示的水属性或风属性怪兽。
function s.indcon(e)
	-- 检查自身场上是否存在满足条件的中央主要怪兽区域的水·风属性怪兽。
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤受到破坏抗性影响的卡片，限定为自身场上除这张卡以外的表侧表示魔法·陷阱卡。
function s.indtg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤自身场上中央主要怪兽区域表侧表示的光属性或暗属性怪兽。
function s.abdfilter(c)
	return c:GetSequence()==2 and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsFaceup()
end
-- 战斗伤害变0效果的发动条件：自身场上中央主要怪兽区域存在表侧表示的光属性或暗属性怪兽。
function s.abdcon(e)
	-- 检查自身场上是否存在满足条件的中央主要怪兽区域的光·暗属性怪兽。
	return Duel.IsExistingMatchingCard(s.abdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

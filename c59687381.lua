--ディフェンスゾーン
-- 效果：
-- ①：以下效果对双方玩家适用。
-- ●自己的主要怪兽区域有怪兽存在的场合，相同纵列的自己的魔法与陷阱区域的卡不会成为对方的效果的对象，不会被对方的效果破坏。
function c59687381.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：以下效果对双方玩家适用。●自己的主要怪兽区域有怪兽存在的场合，相同纵列的自己的魔法与陷阱区域的卡不会成为对方的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(c59687381.tgtg)
	-- 设置不会成为对方（相对于自身控制者）的效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方（相对于自身控制者）的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetTargetRange(0,LOCATION_SZONE)
	-- 设置不会成为对方（相对于对方玩家，即这张卡的控制者）的效果对象
	e3:SetValue(aux.tgsval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方（相对于对方玩家，即这张卡的控制者）的效果破坏
	e4:SetValue(aux.indsval)
	c:RegisterEffect(e4)
end
-- 过滤属于相同控制者且位于主要怪兽区域的怪兽
function c59687381.tgfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 过滤位于魔法与陷阱区域（不含场地），且相同纵列存在属于自身控制者的主要怪兽区域怪兽的卡
function c59687381.tgtg(e,c)
	return c:GetSequence()<5 and c:GetColumnGroup():FilterCount(c59687381.tgfilter,nil,c:GetControler())>0
end

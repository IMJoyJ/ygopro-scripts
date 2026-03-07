--憑依装着－ウィン
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「风灵使 薇茵」和1只风属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c31764353.initial_effect(c)
	-- 效果原文内容：①：这张卡可以把自己场上的表侧表示的1只「风灵使 薇茵」和1只风属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c31764353.spcon)
	e1:SetTarget(c31764353.sptg)
	e1:SetOperation(c31764353.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c31764353.condition)
	c:RegisterEffect(e2)
end
-- 检索满足条件的场上表侧表示怪兽，这些怪兽可以作为特殊召唤的cost被送去墓地。
function c31764353.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查所选的2张怪兽是否满足条件：一张是「风灵使 薇茵」，另一张是风属性怪兽，并且玩家怪兽区有足够空位。
function c31764353.fselect(g,tp)
	-- 检查所选的2张怪兽是否满足条件：一张是「风灵使 薇茵」，另一张是风属性怪兽，并且玩家怪兽区有足够空位。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,37744402,Card.IsAttribute,ATTRIBUTE_WIND)
end
-- 判断是否满足特殊召唤条件：从场上选择2张符合条件的怪兽（一张是「风灵使 薇茵」，另一张是风属性怪兽）并送去墓地。
function c31764353.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有满足条件的怪兽（表侧表示且可作为cost送去墓地）。
	local g=Duel.GetMatchingGroup(c31764353.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c31764353.fselect,2,2,tp)
end
-- 选择满足条件的2张怪兽（一张是「风灵使 薇茵」，另一张是风属性怪兽）并将其送去墓地。
function c31764353.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有满足条件的怪兽（表侧表示且可作为cost送去墓地）。
	local g=Duel.GetMatchingGroup(c31764353.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c31764353.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将之前选择的2张怪兽送去墓地，并清除临时记录。
function c31764353.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片组送去墓地，原因标记为特殊召唤。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断该卡是否为通过①效果特殊召唤的怪兽。
function c31764353.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

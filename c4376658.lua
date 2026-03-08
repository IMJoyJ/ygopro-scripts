--憑依装着－ヒータ
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「火灵使 希塔」和1只炎属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c4376658.initial_effect(c)
	-- 效果原文内容：①：这张卡可以把自己场上的表侧表示的1只「火灵使 希塔」和1只炎属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c4376658.spcon)
	e1:SetTarget(c4376658.sptg)
	e1:SetOperation(c4376658.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c4376658.condition)
	c:RegisterEffect(e2)
end
-- 检索满足条件的场上表侧表示怪兽，这些怪兽可以作为特殊召唤的cost被送去墓地。
function c4376658.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查所选的2张怪兽是否满足条件：一张是「火灵使 希塔」，另一张是炎属性怪兽，并且玩家怪兽区有足够空位。
function c4376658.fselect(g,tp)
	-- 检查所选的2张怪兽是否满足条件：一张是「火灵使 希塔」，另一张是炎属性怪兽，并且玩家怪兽区有足够空位。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,759393,Card.IsAttribute,ATTRIBUTE_FIRE)
end
-- 检查玩家场上是否存在满足条件的2张怪兽（一张是「火灵使 希塔」，另一张是炎属性怪兽），用于特殊召唤的cost。
function c4376658.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有满足条件的怪兽（表侧表示且可以送去墓地）。
	local g=Duel.GetMatchingGroup(c4376658.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c4376658.fselect,2,2,tp)
end
-- 选择满足条件的2张怪兽（一张是「火灵使 希塔」，另一张是炎属性怪兽），并将其标记为特殊召唤的cost。
function c4376658.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有满足条件的怪兽（表侧表示且可以送去墓地）。
	local g=Duel.GetMatchingGroup(c4376658.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c4376658.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将之前选择的2张怪兽从场上送去墓地，完成特殊召唤的cost处理。
function c4376658.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽组以特殊召唤的原因送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断该卡是否为通过①的效果特殊召唤的。
function c4376658.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

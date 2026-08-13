--憑依装着－ウィン
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「风灵使 薇茵」和1只风属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c31764353.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只「风灵使 薇茵」和1只风属性怪兽送去墓地，从手卡·卡组特殊召唤。
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
	-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c31764353.condition)
	c:RegisterEffect(e2)
end
-- 筛选可作为①效果发动素材的怪兽：必须表侧表示且可以作为代价送去墓地。
function c31764353.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查选择的2张素材是否合法：将其送去墓地后己方仍有空余怪兽区域，且其中1张是「风灵使 薇茵」（卡号37744402），另1张是风属性怪兽（顺序不限）。
function c31764353.fselect(g,tp)
	-- 具体判定素材组合：素材送去墓地后场地有空位，并且两张卡中一张为「风灵使 薇茵」，另一张为风属性怪兽（顺序可互换）。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,37744402,Card.IsAttribute,ATTRIBUTE_WIND)
end
-- 特殊召唤规则的条件：当c为nil时默认允许；否则检查控制者场上是否存在1张「风灵使 薇茵」和1只风属性怪兽可供①使用。
function c31764353.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取此卡控制者场上所有满足素材条件的怪兽（表侧表示且可作为代价送去墓地）。
	local g=Duel.GetMatchingGroup(c31764353.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c31764353.fselect,2,2,tp)
end
-- 特殊召唤规则的目标函数：让玩家从符合条件的场上怪兽中选出2张作为素材，选择成功后保存并继续，否则取消。
function c31764353.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前控制者场上可作为素材的怪兽集合（表侧表示且可作为代价送去墓地）。
	local g=Duel.GetMatchingGroup(c31764353.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家提示“请选择要送去墓地的卡”，用于素材选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c31764353.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：取出之前选定的素材组并将其送去墓地，然后清理临时组引用。
function c31764353.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材组送去墓地，原因视为这次特殊召唤的手续/代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ②效果的适用条件：这张卡是通过①的效果特殊召唤成功时（召唤类型为特殊召唤+SUMMON_VALUE_SELF），才具有贯穿伤害效果。
function c31764353.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

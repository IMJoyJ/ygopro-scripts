--憑依装着－アウス
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「地灵使 奥丝」和1只地属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c31887905.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只「地灵使 奥丝」和1只地属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c31887905.spcon)
	e1:SetTarget(c31887905.sptg)
	e1:SetOperation(c31887905.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c31887905.condition)
	c:RegisterEffect(e2)
end
-- 作为“可送去墓地的素材”的过滤条件：要求怪兽表侧表示，并且可以作为COST送去墓地。
function c31887905.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 判断选出的2张素材是否合法：送墓后自己场上仍有可用怪兽区空格，且满足一组为「地灵使 奥丝」、另一组为地属性怪兽的组合（顺序不限）。
function c31887905.fselect(g,tp)
	-- 确认素材组合合法：要么第一张是「地灵使 奥丝」且第二张是地属性，要么第一张是地属性且第二张是「地灵使 奥丝」，同时送墓后自己场上仍有怪兽区空位。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,37970940,Card.IsAttribute,ATTRIBUTE_EARTH)
end
-- 特殊召唤规则效果的发动条件：c为nil时表明规则本身可用；否则检查自己场上是否存在满足spfilter的怪兽，并能选出2张满足fselect的素材。
function c31887905.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足spfilter（表侧表示且可作为COST送墓）的怪兽，作为可选素材集合。
	local g=Duel.GetMatchingGroup(c31887905.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c31887905.fselect,2,2,tp)
end
-- 特殊召唤规则效果发动时的目标处理：让玩家从可选素材中选择2张满足fselect的怪兽，选中后将其保存在效果的LabelObject中以便后续送墓；未选择则发动失败。
function c31887905.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取自己场上所有可作为COST送墓的表侧表示怪兽，用于目标选择。
	local g=Duel.GetMatchingGroup(c31887905.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 弹出“请选择要送去墓地的卡”的选择提示，引导玩家选择素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c31887905.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则效果的实际处理：从LabelObject取出之前选择的素材组，将其送去墓地，然后释放临时保存的卡片组。
function c31887905.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选择的素材卡以“特殊召唤的COST”原因送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 贯穿伤害效果的适用条件：这张卡的召唤方式等于预先定义的“通过①的方法特殊召唤”的特殊召唤类型（SUMMON_TYPE_SPECIAL + SUMMON_VALUE_SELF）。
function c31887905.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

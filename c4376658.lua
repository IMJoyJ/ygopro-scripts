--憑依装着－ヒータ
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「火灵使 希塔」和1只炎属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c4376658.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只「火灵使 希塔」和1只炎属性怪兽送去墓地，从手卡·卡组特殊召唤。
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
	-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c4376658.condition)
	c:RegisterEffect(e2)
end
-- 筛选可作为特殊召唤代价的素材怪兽：必须表侧表示且能够作为代价送去墓地。
function c4376658.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查素材组g是否可用：将g中的卡作为代价送去墓地后自己场上仍有怪兽区空位，且g中同时包含1只「火灵使 希塔」（卡号759393）和1只炎属性怪兽（顺序不限）。
function c4376658.fselect(g,tp)
	-- 返回组合合法性：消耗素材后有空位，且素材恰好由「火灵使 希塔」和炎属性怪兽组成。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,759393,Card.IsAttribute,ATTRIBUTE_FIRE)
end
-- 特殊召唤规则的条件：c为空时视为允许（规则询问）；否则检查自己场上是否存在2张满足spfilter的怪兽，且它们能满足fselect的组合要求。
function c4376658.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且可作为代价送去墓地的怪兽，作为候选素材集合。
	local g=Duel.GetMatchingGroup(c4376658.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c4376658.fselect,2,2,tp)
end
-- 选择特殊召唤素材：从候选素材中选出2张满足组合条件的卡，选中后保存到效果e的LabelObject，并返回true；若取消选择则返回false。
function c4376658.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且可作为代价送去墓地的怪兽，作为候选素材集合。
	local g=Duel.GetMatchingGroup(c4376658.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c4376658.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤处理：取出之前保存的素材组，将其送去墓地，并清理临时组对象。
function c4376658.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的素材卡以特殊召唤为由（REASON_SPSUMMON）送入墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 贯穿伤害效果的发动条件：这张卡的召唤类型为通过①的效果进行的特殊召唤（SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）。
function c4376658.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

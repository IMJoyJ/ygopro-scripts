--憑依装着－エリア
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「水灵使 艾莉娅」和1只水属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c68881649.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只「水灵使 艾莉娅」和1只水属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c68881649.spcon)
	e1:SetTarget(c68881649.sptg)
	e1:SetOperation(c68881649.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c68881649.condition)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示且可以作为cost送去墓地的怪兽
function c68881649.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查选取的卡片组是否满足怪兽区域空位要求，且包含1只「水灵使 艾莉娅」和1只水属性怪兽
function c68881649.fselect(g,tp)
	-- 检查选取的卡片组是否满足怪兽区域空位要求，且包含1只「水灵使 艾莉娅」和1只水属性怪兽
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,74364659,Card.IsAttribute,ATTRIBUTE_WATER)
end
-- 特殊召唤规则的条件判定，检查自己场上是否存在满足特殊召唤条件的卡片组合
function c68881649.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且可以作为cost送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c68881649.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c68881649.fselect,2,2,tp)
end
-- 特殊召唤规则的目标选择，让玩家选择用于特殊召唤的2只怪兽并记录
function c68881649.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且可以作为cost送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c68881649.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家发送“请选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c68881649.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作处理，将选中的怪兽送去墓地
function c68881649.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的素材送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查自身是否是通过其①的方法（自身特殊召唤规则）特殊召唤的
function c68881649.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

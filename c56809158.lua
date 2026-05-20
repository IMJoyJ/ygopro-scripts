--紅蓮の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
-- ②：从自己墓地把1只「机界骑士」怪兽除外，以和这张卡相同纵列1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c56809158.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56809158+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56809158.hspcon)
	e1:SetValue(c56809158.hspval)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只「机界骑士」怪兽除外，以和这张卡相同纵列1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56809158,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c56809158.cost)
	e3:SetTarget(c56809158.target)
	e3:SetOperation(c56809158.operation)
	c:RegisterEffect(e3)
end
-- 过滤相同纵列有其他卡片存在的卡片（即该卡所在的纵列卡片数量大于0，加上自身即至少有2张卡存在）
function c56809158.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 特殊召唤规则的条件判定函数：检查自己场上是否存在符合“相同纵列有2张以上卡存在”的可用怪兽区域
function c56809158.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有“所在纵列有其他卡存在”的卡片组
	local lg=Duel.GetMatchingGroup(c56809158.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡片，计算出所有满足特殊召唤条件的纵列对应的自己怪兽区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 检查在这些满足条件的纵列对应的自己怪兽区域中，是否有可用的空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的位置选择函数：计算并返回允许特殊召唤的自己怪兽区域（zone）
function c56809158.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有“所在纵列有其他卡存在”的卡片组
	local lg=Duel.GetMatchingGroup(c56809158.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡片，计算出所有满足特殊召唤条件的纵列对应的自己怪兽区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 过滤自己墓地可以作为发动代价除外的「机界骑士」怪兽
function c56809158.costfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价：从自己墓地把1只「机界骑士」怪兽除外
function c56809158.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的「机界骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56809158.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只「机界骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c56809158.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤和这张卡相同纵列的表侧表示怪兽
function c56809158.filter(c,g)
	return c:IsFaceup() and g:IsContains(c)
end
-- 效果的目标选择：以和这张卡相同纵列的1只表侧表示怪兽为对象
function c56809158.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	if chkc then return c56809158.filter(chkc,cg) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为对象的、和这张卡相同纵列的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c56809158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,cg) end
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择相同纵列的1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56809158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,cg)
	-- 设置效果处理信息：准备破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理：将作为对象的怪兽破坏
function c56809158.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

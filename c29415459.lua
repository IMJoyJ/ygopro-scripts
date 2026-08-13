--黄華の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
-- ②：从自己墓地把1只「机界骑士」怪兽除外，以和这张卡相同纵列1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c29415459.initial_effect(c)
	-- 对应效果原文：这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,29415459+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c29415459.hspcon)
	e1:SetValue(c29415459.hspval)
	c:RegisterEffect(e1)
	-- 对应效果原文：②：从自己墓地把1只「机界骑士」怪兽除外，以和这张卡相同纵列1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29415459,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c29415459.cost)
	e3:SetTarget(c29415459.target)
	e3:SetOperation(c29415459.operation)
	c:RegisterEffect(e3)
end
-- 筛选函数：判断卡片c所在纵列是否还有其他卡（即该纵列存在至少2张卡），用于找出满足‘相同纵列有卡2张以上’的纵列参照物。
function c29415459.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- ①的特殊召唤规则条件：若正在询问规则本身则直接允许；否则统计场上所有满足“纵列有其他卡”的卡片所对应的主怪兽区域，并检查这些区域中是否存在空位，若有则此卡可从手牌特殊召唤到该纵列的自己场上。
function c29415459.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 取得双方场上所有满足cfilter的卡片，即所有所在纵列还有其他卡的卡，作为后续计算可特殊召唤区域的候选集合。
	local lg=Duel.GetMatchingGroup(c29415459.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历候选卡片组lg中的每张卡，逐个累加其所处纵列对应的主怪兽区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 检查计算出的纵列区域中是否至少有一个空位可供特殊召唤，从而决定是否满足①的特殊召唤条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- ①的特殊召唤规则值函数：重新计算所有满足条件的纵列对应的主怪兽区域（zone），并返回表示形式0（由玩家选择）与可用区域zone，使此卡可特殊召唤到这些区域。
function c29415459.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 取得双方场上所有满足cfilter的卡片，用于计算允许特殊召唤的纵列区域。
	local lg=Duel.GetMatchingGroup(c29415459.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历候选卡片，按位或（bit.bor）累加每张卡所在纵列对应的主怪兽区域，得到可用的zone位集合。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 费用筛选：对象卡必须是「机界骑士」怪兽（setname=0x10c），且可以从墓地作为代价除外。
function c29415459.costfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②的发动代价：从自己墓地选择1只满足条件的「机界骑士」怪兽除外作为cost；chk==0时仅检查是否存在可用代价，否则提示玩家选择并执行除外。
function c29415459.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己墓地是否存在至少1只可作为除外代价的「机界骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c29415459.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示‘请选择要除外的卡’的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足costfilter的「机界骑士」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c29415459.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标筛选：卡片c必须是魔法·陷阱卡，并且在本卡同一纵列卡片组g中。
function c29415459.filter(c,g)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and g:IsContains(c)
end
-- ②的发动目标处理：获取与本卡同一纵列的所有卡片，检测是否存在可选的魔法·陷阱卡；存在则提示选择其中1张并设为效果对象，同时设置破坏的操作信息。
function c29415459.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return c29415459.filter(chkc,cg) and chkc:IsOnField() end
	-- 目标检测：确认场上（双方）是否存在至少1张与本卡同一纵列的魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c29415459.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,cg) end
	-- 显示‘请选择要破坏的卡’的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张与本卡同一纵列的魔法·陷阱卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c29415459.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,cg)
	-- 设置操作信息：声明本连锁将破坏1张卡（CATEGORY_DESTROY），供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②的效果处理：取得效果对象，若对象仍与此效果关联（未被移离或失效），则将其破坏。
function c29415459.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的第一个效果对象（本次发动选择的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏该对象卡片。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

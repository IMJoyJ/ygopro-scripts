--極星天ヴァルキュリア
-- 效果：
-- ①：这张卡召唤成功时，对方场上有怪兽存在，自己场上没有这张卡以外的卡存在的场合，从手卡把2只「极星」怪兽除外才能发动。在自己场上把2只「英灵衍生物」（战士族·地·4星·攻/守1000）守备表示特殊召唤。
function c40844552.initial_effect(c)
	-- 效果原文：①：这张卡召唤成功时，对方场上有怪兽存在，自己场上没有这张卡以外的卡存在的场合，从手卡把2只「极星」怪兽除外才能发动。在自己场上把2只「英灵衍生物」（战士族·地·4星·攻/守1000）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40844552,0))  --"特殊召唤Token"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c40844552.condition)
	e1:SetCost(c40844552.cost)
	e1:SetTarget(c40844552.target)
	e1:SetOperation(c40844552.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查对方场上是否有怪兽，且自己场上除这张卡外没有其他卡。
function c40844552.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：对方场上有怪兽存在，自己场上没有这张卡以外的卡存在的场合
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1
end
-- 效果作用：定义用于过滤手卡中「极星」怪兽的条件。
function c40844552.cfilter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：支付代价，从手卡除外2只「极星」怪兽。
function c40844552.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足除外2只「极星」怪兽的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c40844552.cfilter,tp,LOCATION_HAND,0,2,nil) end
	-- 效果作用：提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择满足条件的2张手卡。
	local g=Duel.SelectMatchingCard(tp,c40844552.cfilter,tp,LOCATION_HAND,0,2,2,nil)
	-- 效果作用：将选中的卡除外作为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果作用：设置效果处理的目标，判断是否可以特殊召唤2只英灵衍生物。
function c40844552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果作用：判断自己场上是否有足够的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 效果作用：判断是否可以特殊召唤英灵衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,40844553,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 效果作用：设置连锁操作信息，表示将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 效果作用：设置连锁操作信息，表示将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果作用：执行效果处理，特殊召唤2只英灵衍生物。
function c40844552.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：判断自己场上是否有足够的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果作用：判断是否可以特殊召唤英灵衍生物。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,40844553,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 效果作用：创建一只英灵衍生物。
		local token=Duel.CreateToken(tp,40844553)
		-- 效果作用：将英灵衍生物以守备表示特殊召唤。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 效果作用：完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end

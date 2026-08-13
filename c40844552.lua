--極星天ヴァルキュリア
-- 效果：
-- ①：这张卡召唤成功时，对方场上有怪兽存在，自己场上没有这张卡以外的卡存在的场合，从手卡把2只「极星」怪兽除外才能发动。在自己场上把2只「英灵衍生物」（战士族·地·4星·攻/守1000）守备表示特殊召唤。
function c40844552.initial_effect(c)
	-- ①：这张卡召唤成功时，对方场上有怪兽存在，自己场上没有这张卡以外的卡存在的场合，从手卡把2只「极星」怪兽除外才能发动。在自己场上把2只「英灵衍生物」（战士族·地·4星·攻/守1000）守备表示特殊召唤。
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
-- 发动条件判定：对方场上存在怪兽，且己方场上不存在这张卡以外的卡。
function c40844552.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽区存在怪兽，且己方场上卡片总数不超过1（即只有这张卡自身）。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1
end
-- 定义筛选条件：手卡中满足「极星」字段、是怪兽卡，并且可以作为代价除外的卡。
function c40844552.cfilter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：确认手卡存在2只符合条件的「极星」怪兽，然后从手卡选择2只除外作为发动代价。
function c40844552.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：己方手卡中是否存在至少2只满足条件的「极星」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c40844552.cfilter,tp,LOCATION_HAND,0,2,nil) end
	-- 弹出选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从己方手卡中选择2只满足条件的「极星」怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c40844552.cfilter,tp,LOCATION_HAND,0,2,2,nil)
	-- 将选择的2只「极星」怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时合法性检查并设定信息：确认己方不受「青眼精灵龙」的同时特殊召唤限制、怪兽区至少2个空格且能特殊召唤衍生物，然后设置操作信息。
function c40844552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方怪兽区域是否有至少2个可用空格，用于特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认己方玩家可以将「英灵衍生物」（战士族·地·4星·攻/守1000）以表侧守备表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,40844553,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次效果将生成2只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果包含2只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若己方不受「青眼精灵龙」影响且仍有足够空格、能够特殊召唤，则生成2只「英灵衍生物」并守备表示特殊召唤到己方场上。
function c40844552.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认己方怪兽区可用空格不少于2，否则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时再次确认可以特殊召唤「英灵衍生物」，否则中断处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,40844553,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 创建1只「英灵衍生物」衍生物（卡号40844553）。
		local token=Duel.CreateToken(tp,40844553)
		-- 将衍生物以表侧守备表示特殊召唤到己方场上（作为同时特殊召唤流程的一步）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成整个特殊召唤流程，结束同时特殊召唤多只怪兽的处理。
	Duel.SpecialSummonComplete()
end

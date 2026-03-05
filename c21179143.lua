--レプティレス・スポーン
-- 效果：
-- 把自己墓地存在的1只名字带有「爬虫妖」的怪兽从游戏中除外发动。在自己场上把2只「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤。
function c21179143.initial_effect(c)
	-- 效果原文内容：把自己墓地存在的1只名字带有「爬虫妖」的怪兽从游戏中除外发动。在自己场上把2只「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21179143.cost)
	e1:SetTarget(c21179143.target)
	e1:SetOperation(c21179143.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测墓地是否存在名字带有「爬虫妖」的怪兽
function c21179143.cfilter(c)
	return c:IsSetCard(0x3c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，检查是否满足除外条件并选择除外1只符合条件的怪兽
function c21179143.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足除外条件，检查自己墓地是否存在至少1只名字带有「爬虫妖」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21179143.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c21179143.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数，检查是否满足特殊召唤条件
function c21179143.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查是否可以特殊召唤2只「爬虫妖衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果发动函数，执行特殊召唤2只「爬虫妖衍生物」
function c21179143.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上是否有至少2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查是否可以特殊召唤2只「爬虫妖衍生物」
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		-- 创建一只「爬虫妖衍生物」
		local token=Duel.CreateToken(tp,21179144)
		-- 将创建的衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end

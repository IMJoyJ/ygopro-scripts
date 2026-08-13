--レプティレス・スポーン
-- 效果：
-- 把自己墓地存在的1只名字带有「爬虫妖」的怪兽从游戏中除外发动。在自己场上把2只「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤。
function c21179143.initial_effect(c)
	-- 把自己墓地存在的1只名字带有「爬虫妖」的怪兽从游戏中除外发动。在自己场上把2只「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21179143.cost)
	e1:SetTarget(c21179143.target)
	e1:SetOperation(c21179143.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：卡为「爬虫妖」字段的怪兽，且可以作为代价从墓地除外。
function c21179143.cfilter(c)
	return c:IsSetCard(0x3c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：先检查墓地是否存在满足条件的「爬虫妖」怪兽，然后提示玩家选择1张，将选择的卡表侧表示除外作为发动代价。
function c21179143.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少1只满足条件的「爬虫妖」怪兽可供除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c21179143.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的「爬虫妖」怪兽。
	local g=Duel.SelectMatchingCard(tp,c21179143.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽卡表侧表示从游戏中除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标条件判定：发动时确认没有「青眼精灵龙」限制（不能同时特殊召唤2只以上怪兽）、自己主要怪兽区空位大于1、且可以特殊召唤「爬虫妖衍生物」，否则不能发动。
function c21179143.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区是否有至少2个可用区域，以便特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己是否能够特殊召唤指定参数的「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 登记操作信息：本效果将生成2只衍生物（CATEGORY_TOKEN），用于连锁处理和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 登记操作信息：本效果将进行2只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：再次确认「青眼精灵龙」限制、主要怪兽区空位和特殊召唤许可后，连续创建2只「爬虫妖衍生物」并依次特殊召唤，最后完成特殊召唤。
function c21179143.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认自己主要怪兽区至少有2个可用区域，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时再次确认可以特殊召唤「爬虫妖衍生物」，否则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		-- 创建1只卡号为21179144的「爬虫妖衍生物」衍生物。
		local token=Duel.CreateToken(tp,21179144)
		-- 将衍生物以表侧表示（攻击表示）特殊召唤，作为连续特殊召唤流程中的一步。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有特殊召唤步骤，正式确定特殊召唤成功。
	Duel.SpecialSummonComplete()
end

--幻魔の殉教者
-- 效果：
-- ①：这张卡以外的自己手卡有2张以上存在，自己场上有「神炎皇 乌利亚」或者「降雷皇 哈蒙」存在的场合，把手卡全部送去墓地才能发动。在自己场上把3只「幻魔的殉教者衍生物」（恶魔族·暗·1星·攻/守0）攻击表示特殊召唤。
function c93224848.initial_effect(c)
	-- 注册卡片记有「神炎皇 乌利亚」和「降雷皇 哈蒙」的卡名
	aux.AddCodeList(c,6007213,32491822)
	-- ①：这张卡以外的自己手卡有2张以上存在，自己场上有「神炎皇 乌利亚」或者「降雷皇 哈蒙」存在的场合，把手卡全部送去墓地才能发动。在自己场上把3只「幻魔的殉教者衍生物」（恶魔族·暗·1星·攻/守0）攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c93224848.condition)
	e1:SetCost(c93224848.cost)
	e1:SetTarget(c93224848.target)
	e1:SetOperation(c93224848.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示存在的「神炎皇 乌利亚」或「降雷皇 哈蒙」
function c93224848.filter(c)
	return c:IsFaceup() and c:IsCode(6007213,32491822)
end
-- 检查是否满足发动条件：这张卡以外的自己手卡有2张以上存在，且自己场上有「神炎皇 乌利亚」或者「降雷皇 哈蒙」存在
function c93224848.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡以外的自己手卡是否有2张以上存在
	return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,2,e:GetHandler())
		-- 检查自己场上是否存在「神炎皇 乌利亚」或者「降雷皇 哈蒙」
		and Duel.IsExistingMatchingCard(c93224848.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤不能作为发动代价送去墓地的卡
function c93224848.cfilter(c)
	return not c:IsAbleToGraveAsCost()
end
-- 检查并执行发动代价：把手卡全部送去墓地
function c93224848.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中的所有卡是否都能作为代价送去墓地
	if chk==0 then return not Duel.IsExistingMatchingCard(c93224848.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 获取自己手卡的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将所有手卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检查是否能特殊召唤3只衍生物，并设置操作信息
function c93224848.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有3个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查玩家是否可以特殊召唤「幻魔的殉教者衍生物」（恶魔族·暗·1星·攻/守0）攻击表示
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93224849,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置操作信息：产生3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置操作信息：特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理：在自己场上把3只「幻魔的殉教者衍生物」攻击表示特殊召唤
function c93224848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的主要怪兽区域是否有3个以上的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查玩家是否可以特殊召唤「幻魔的殉教者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93224849,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then
		for i=1,3 do
			-- 创建「幻魔的殉教者衍生物」卡片
			local token=Duel.CreateToken(tp,93224849)
			-- 逐步特殊召唤衍生物到自己场上，以表侧攻击表示
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end

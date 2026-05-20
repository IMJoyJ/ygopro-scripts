--極限への衝動
-- 效果：
-- 把2张手卡送去墓地发动。在自己场上把2只「灵魂衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。这衍生物不能为上级召唤以外而解放。
function c82324105.initial_effect(c)
	-- 把2张手卡送去墓地发动。在自己场上把2只「灵魂衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。这衍生物不能为上级召唤以外而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c82324105.cost)
	e1:SetTarget(c82324105.target)
	e1:SetOperation(c82324105.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查并执行将2张手卡送去墓地的操作
function c82324105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少2张可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡中选择2张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,2,2,e:GetHandler())
	-- 将选中的手卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动条件与目标检查：检查是否满足特殊召唤2只衍生物的条件
function c82324105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤指定的「灵魂衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,82324106,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息，表明此效果包含产生2只衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表明此效果包含特殊召唤2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：在自己场上特殊召唤2只「灵魂衍生物」，并施加解放限制
function c82324105.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己的主要怪兽区域是否有2个以上的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤指定的「灵魂衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,82324106,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 创建「灵魂衍生物」的卡片数据
			local token=Duel.CreateToken(tp,82324106)
			-- 将衍生物以表侧表示特殊召唤到场上（单步处理）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 这衍生物不能为上级召唤以外而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 完成所有怪兽的特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end

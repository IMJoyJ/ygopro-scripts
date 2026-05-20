--アサルト・ガンドッグ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把「突击枪犬」任意数量特殊召唤。
function c72714226.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把「突击枪犬」任意数量特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72714226,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c72714226.condition)
	e1:SetTarget(c72714226.target)
	e1:SetOperation(c72714226.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身是否在墓地且是被战斗破坏。
function c72714226.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中卡名为「突击枪犬」且可以特殊召唤的怪兽。
function c72714226.filter(c,e,tp)
	return c:IsCode(72714226) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与检测：检查己方场上是否有空位，以及卡组中是否存在至少1张满足条件的「突击枪犬」。
function c72714226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的「突击枪犬」。
		and Duel.IsExistingMatchingCard(c72714226.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤至少1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行：计算可召唤数量（考虑青眼精灵龙等限制），从卡组选择任意数量（不超过空位数）的「突击枪犬」特殊召唤。
function c72714226.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的怪兽区域空格数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1到ct（可用空格数）张「突击枪犬」。
	local g=Duel.SelectMatchingCard(tp,c72714226.filter,tp,LOCATION_DECK,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

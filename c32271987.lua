--フェデライザー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只二重怪兽送去墓地，从自己卡组抽1张卡。
function c32271987.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只二重怪兽送去墓地，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32271987,0))  --"送墓抽卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c32271987.condition)
	e1:SetTarget(c32271987.target)
	e1:SetOperation(c32271987.operation)
	c:RegisterEffect(e1)
end
-- 检查效果触发条件：自身处于墓地且是被战斗破坏送去的。
function c32271987.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选卡组中符合“二重怪兽”且可以送去墓地的卡片。
function c32271987.filter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToGrave()
end
-- 发动时判定条件并设置操作信息：卡组中须存在可送墓的二重怪兽且玩家可以抽卡，若卡组只剩1张且正是那张二重怪兽则不能发动；同时登记送墓和抽卡的处理信息。
function c32271987.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 统计玩家卡组中可送去墓地的二重怪兽数量。
		local ct=Duel.GetMatchingGroupCount(c32271987.filter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中可送墓的二重怪兽只有1张且卡组总张数也只有1张，则送墓后卡组为空导致无法抽卡，因此不能发动。
		if ct==1 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==1 then return false end
		-- 发动条件成立：玩家可以抽1张卡，且卡组中存在至少1张符合条件的二重怪兽。
		return Duel.IsPlayerCanDraw(tp,1) and ct>=1 end
	-- 登记“从卡组把1张卡送去墓地”的操作信息，处理时再确定具体卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 登记“抽1张卡”的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从卡组选择1只二重怪兽送去墓地，之后抽1张卡。
function c32271987.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只符合条件的二重怪兽。
	local g=Duel.SelectMatchingCard(tp,c32271987.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 中断当前效果链，使送墓与后续抽卡不在同一时点处理。
		Duel.BreakEffect()
		-- 玩家抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

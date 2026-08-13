--森羅の仙樹 レギア
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地，从卡组抽1张卡。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，从自己卡组上面把最多3张卡确认，用喜欢的顺序回到卡组上面。
function c25824484.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地，从卡组抽1张卡。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25824484,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25824484.target)
	e1:SetOperation(c25824484.operation)
	c:RegisterEffect(e1)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，从自己卡组上面把最多3张卡确认，用喜欢的顺序回到卡组上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25824484,1))  --"确认卡组顺序"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c25824484.sdcon)
	e2:SetOperation(c25824484.sdop)
	c:RegisterEffect(e2)
end
-- 发动时的合法性检查：确认自己可以把卡组最上方1张卡送去墓地（效果发动的条件）。
function c25824484.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若玩家不能将卡组最上方1张卡送去墓地，则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理：翻开卡组最上方1张卡；若是植物族怪兽则将其送去墓地并抽1张卡，否则将其放回卡组最下面。
function c25824484.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认玩家仍可把卡组最上方1张卡送去墓地，否则中止处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向双方确认卡组最上方1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方1张卡的卡片对象。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用本次操作的洗牌检测，避免后续从卡组送墓/抽卡后触发不必要的洗牌。
		Duel.DisableShuffleCheck()
		-- 将翻开的植物族怪兽以“效果+翻开”的原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
		-- 从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		-- 将非植物族的翻开卡放回卡组最下面。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 诱发条件：这张卡从卡组被卡的效果翻开并因此送去墓地。
function c25824484.sdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 效果处理：从自己卡组上面选择1～3张卡确认，并以任意顺序放回卡组上面。
function c25824484.sdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中卡的数量（用于判断可选数量）。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 提示玩家选择要确认的卡片数量。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25824484,2))  --"请选择要确认的数量"
		-- 卡组只有2张时，宣言选择确认1张或2张。
		if ct==2 then ac=Duel.AnnounceNumber(tp,1,2)
		-- 卡组有3张及以上时，宣言选择确认1张、2张或3张。
		else ac=Duel.AnnounceNumber(tp,1,2,3) end
	end
	-- 对卡组最上方ac张卡进行排序，实现按玩家喜欢的顺序放回卡组上面。
	Duel.SortDecktop(tp,tp,ac)
end

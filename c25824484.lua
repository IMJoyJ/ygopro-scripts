--森羅の仙樹 レギア
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地，从卡组抽1张卡。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，从自己卡组上面把最多3张卡确认，用喜欢的顺序回到卡组上面。
function c25824484.initial_effect(c)
	-- 效果原文：1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地，从卡组抽1张卡。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25824484,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25824484.target)
	e1:SetOperation(c25824484.operation)
	c:RegisterEffect(e1)
	-- 效果原文：此外，卡组的这张卡被卡的效果翻开送去墓地的场合，从自己卡组上面把最多3张卡确认，用喜欢的顺序回到卡组上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25824484,1))  --"确认卡组顺序"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c25824484.sdcon)
	e2:SetOperation(c25824484.sdop)
	c:RegisterEffect(e2)
end
-- 检查是否可以翻开卡组最上方的1张卡
function c25824484.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果不能翻开卡组最上方的1张卡则返回
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果执行函数：翻开卡组最上方的1张卡，根据是否为植物族进行不同处理
function c25824484.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果不能翻开卡组最上方的1张卡则返回
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用接下来的卡组洗切检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡以效果和翻开原因送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		-- 将翻开的卡移至卡组最下方
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 判断此卡是否从卡组被翻开送去墓地
function c25824484.sdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 效果执行函数：确认卡组最上方最多3张卡并按顺序放回卡组上方
function c25824484.sdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组中的卡数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 提示玩家选择要确认的数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25824484,2))  --"请选择要确认的数量"
		-- 当卡组有2张卡时，让玩家宣言1或2
		if ct==2 then ac=Duel.AnnounceNumber(tp,1,2)
		-- 当卡组有3张或以上卡时，让玩家宣言1、2或3
		else ac=Duel.AnnounceNumber(tp,1,2,3) end
	end
	-- 对玩家卡组最上方的指定数量卡进行排序
	Duel.SortDecktop(tp,tp,ac)
end

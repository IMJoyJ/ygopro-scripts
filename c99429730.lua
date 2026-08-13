--森羅の番人 オーク
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。从自己卡组上面把最多3张卡翻开。翻开的卡之中有植物族怪兽的场合，那些卡全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从自己墓地选择这张卡以外的1只植物族怪兽回到卡组最上面。
function c99429730.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。从自己卡组上面把最多3张卡翻开。翻开的卡之中有植物族怪兽的场合，那些卡全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99429730,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c99429730.target)
	e1:SetOperation(c99429730.operation)
	c:RegisterEffect(e1)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从自己墓地选择这张卡以外的1只植物族怪兽回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99429730,2))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c99429730.tdcon)
	e2:SetTarget(c99429730.tdtg)
	e2:SetOperation(c99429730.tdop)
	c:RegisterEffect(e2)
end
-- 第一个效果的发动条件检查：在效果发动时（chk==0）确认自己卡组至少能将1张卡送去墓地，否则不能发动。
function c99429730.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时点的合法性判定：返回我方是否能把卡组最上方1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理起始：若卡组已无卡可翻开则终止处理；计算可翻开的张数上限（不超过卡组剩余数量，最多3张），生成1至该上限的可选数量数组供玩家选择。
function c99429730.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认我方可以把卡组最上方1张卡送去墓地，若不能则终止效果处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 取得我方卡组当前的卡片总数量，用于限制最多翻开3张。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>3 then ct=3 end
	local t={}
	for i=1,ct do t[i]=i end
	-- 向玩家显示提示消息，要求选择要翻开的卡片数量。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(99429730,1))  --"请选择要翻开的数量"
	-- 让玩家从可选数量中宣言一个实际翻开的数量，赋值给ac。
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 将卡组最上方ac张卡展示给双方确认。
	Duel.ConfirmDecktop(tp,ac)
	-- 获取卡组最上方ac张卡组成的卡组对象，用于筛选其中的植物族怪兽。
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 关闭下一次卡组操作后的自动洗切检测，保证从卡组顶端移动卡片到墓地或卡组底部时保持确定顺序，不额外洗切。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡中所有植物族怪兽以效果原因及翻开原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让玩家对剩余的非植物族翻开卡进行排序，以决定它们返回卡组最底部的顺序。
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 取卡组最上方1张卡，即玩家在排序中放在最上面的那张剩余卡片。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将这张卡按玩家决定的顺序移动到卡组最底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 第二个效果的发动条件判定：此卡被送去墓地前位于卡组，且是作为卡组翻开的卡片被送去墓地。
function c99429730.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 筛选函数：选择墓地中植物族且可以返回卡组的怪兽作为可回收对象。
function c99429730.filter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToDeck()
end
-- 第二个效果的发动目标处理：从自己墓地选择这张卡以外的1只植物族怪兽，并将其设定为效果对象；同时进行合法性检查。
function c99429730.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99429730.filter(chkc) end
	-- 发动时点检查：确认自己墓地存在1只满足条件的植物族怪兽（排除此卡自身）。
	if chk==0 then return Duel.IsExistingTarget(c99429730.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择返回卡组的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只符合条件的植物族怪兽，并将其锁定为效果处理对象。
	local g=Duel.SelectTarget(tp,c99429730.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置当前连锁的操作信息为回卡组效果，目标为所选卡，数量1，供其他卡牌响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 第二个效果的实际处理：将选定的植物族怪兽从墓地返回持有者卡组最上方。
function c99429730.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理时锁定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把该对象卡以效果原因送回卡组最上方。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

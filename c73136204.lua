--森羅の渡し守 ロータス
-- 效果：
-- 1回合1次，可以把对方场上的卡数量的卡从自己卡组上面翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择「森罗的渡守 莲花」以外的自己墓地最多5张名字带有「森罗」的卡用喜欢的顺序回到卡组下面。
function c73136204.initial_effect(c)
	-- 1回合1次，可以把对方场上的卡数量的卡从自己卡组上面翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73136204,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c73136204.target)
	e1:SetOperation(c73136204.operation)
	c:RegisterEffect(e1)
	-- 卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择「森罗的渡守 莲花」以外的自己墓地最多5张名字带有「森罗」的卡用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73136204,2))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c73136204.tdcon)
	e2:SetTarget(c73136204.tdtg)
	e2:SetOperation(c73136204.tdop)
	c:RegisterEffect(e2)
end
-- 1效果的发动准备（检查对方场上的卡数量，以及自身卡组是否有足够数量的卡可以送去墓地）
function c73136204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取对方场上的卡片数量
		local ac=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
		-- 判定对方场上是否有卡，且自己是否能将对应数量的卡从卡组送去墓地
		return ac>0 and Duel.IsPlayerCanDiscardDeck(tp,ac)
	end
end
-- 1效果的处理（翻开卡组，将植物族怪兽送去墓地，其余卡按喜欢顺序放回卡组最下方）
function c73136204.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡片数量
	local ac=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 若对方场上没有卡，或自己无法将对应数量的卡送去墓地，则不处理
	if ac==0 or not Duel.IsPlayerCanDiscardDeck(tp,ac) then return end
	-- 确认（翻开）自己卡组最上方对应数量的卡
	Duel.ConfirmDecktop(tp,ac)
	-- 获取自己卡组最上方对应数量的卡片组
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 禁用接下来的洗卡检测（防止因卡片离开卡组而自动洗牌）
		Duel.DisableShuffleCheck()
		-- 将翻开的植物族怪兽因效果且作为翻开的状态送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让玩家对卡组最上方的剩余卡片进行排序
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 获取当前卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 2效果的发动条件（此卡原本在卡组，且因被翻开而送去墓地）
function c73136204.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 2效果的过滤条件（自己墓地中「森罗的渡守 莲花」以外的名字带有「森罗」且可以回到卡组的卡）
function c73136204.filter(c)
	return c:IsSetCard(0x90) and not c:IsCode(73136204) and c:IsAbleToDeck()
end
-- 2效果的发动准备（选择自己墓地最多5张「森罗」卡作为对象）
function c73136204.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73136204.filter(chkc) end
	-- 判定自己墓地是否存在至少1张满足条件的「森罗」卡
	if chk==0 then return Duel.IsExistingTarget(c73136204.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1到5张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c73136204.filter,tp,LOCATION_GRAVE,0,1,5,nil)
	-- 设置效果处理信息为“将选中的卡片送回卡组”
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 2效果的处理（将选中的卡放回卡组最下方，并由玩家决定顺序）
function c73136204.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将这些卡先放回卡组最上方（以便后续进行排序）
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		-- 获取本次操作中实际移动到卡组的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==0 then return end
		-- 让玩家对放回卡组最上方的这些卡进行排序
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取当前卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方（通过循环实现将所有放回的卡按排序后的顺序移到卡组最下方）
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end

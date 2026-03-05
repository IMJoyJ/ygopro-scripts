--イビリチュア・テトラオーグル
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方可以丢弃1张手卡让这个效果无效。没丢弃的场合，双方玩家把宣言的种类的1张卡从卡组送去墓地。
function c21496848.initial_effect(c)
	c:EnableReviveLimit()
	-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21496848,0))  --"宣言卡种送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c21496848.target)
	e1:SetOperation(c21496848.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件，确保双方卡组都有卡
function c21496848.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，确保双方卡组都有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 提示玩家选择卡的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言卡的种类
	local ac=Duel.AnnounceType(tp)
	e:SetLabel(ac)
	-- 设置效果处理信息，确定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 对方可以丢弃1张手卡让这个效果无效。没丢弃的场合，双方玩家把宣言的种类的1张卡从卡组送去墓地。
function c21496848.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方手牌数量是否大于0且当前连锁效果可被无效
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsChainDisablable(0)
		-- 询问对方是否要丢弃手牌以无效效果
		and Duel.SelectYesNo(1-tp,aux.Stringid(21496848,4)) then  --"是否要丢弃手牌？"
		-- 让对方丢弃1张手牌
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		-- 使当前连锁效果无效
		Duel.NegateEffect(0)
		return
	end
	local ty=TYPE_MONSTER
	if e:GetLabel()==1 then ty=TYPE_SPELL
	elseif e:GetLabel()==2 then ty=TYPE_TRAP end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并加入g1
	local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,ty)
	-- 提示对方选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并加入g2
	local g2=Duel.SelectMatchingCard(1-tp,Card.IsType,1-tp,LOCATION_DECK,0,1,1,nil,ty)
	g1:Merge(g2)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g1,REASON_EFFECT)
end

--黒蠍－逃げ足のチック
-- 效果：
-- 这张卡对对方造成战斗伤害时，从下列效果中选择1项发动：
-- ●将场上1张卡弹回持有者手卡。
-- ●检视对方卡组最上面1张卡（对方不能确认这张卡），并选择将其放回对方卡组最上面或最下面。
function c61587183.initial_effect(c)
	-- 这张卡对对方造成战斗伤害时，从下列效果中选择1项发动：●将场上1张卡弹回持有者手卡。●检视对方卡组最上面1张卡（对方不能确认这张卡），并选择将其放回对方卡组最上面或最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61587183,0))  --"选择一个效果发动"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c61587183.condition)
	e1:SetTarget(c61587183.target)
	e1:SetOperation(c61587183.operation)
	c:RegisterEffect(e1)
end
-- 判断是否是对对方造成战斗伤害
function c61587183.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时的目标选择与效果分支选择处理
function c61587183.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 在发动检查时，判断对方卡组是否有卡（是否满足第二个效果的发动条件）
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 或者场上是否存在可以返回手牌的卡（是否满足第一个效果的发动条件）
		or Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local op=0
	-- 提示玩家选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(61587183,0))  --"选择一个效果发动"
	-- 如果场上存在可以返回手牌的卡
	if Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 并且对方卡组有卡，则两个效果都可以选择
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 then
		-- 让玩家在“弹回手牌”和“检视卡组”两个效果中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(61587183,1),aux.Stringid(61587183,2))  --"将场上1张卡弹回持有者手牌。/检视对方牌组最上面1张卡。"
	-- 如果只有对方卡组有卡（场上没有可弹回的卡）
	elseif Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 then
		-- 强制选择“检视对方卡组最上面1张卡”的效果
		Duel.SelectOption(tp,aux.Stringid(61587183,2))  --"检视对方牌组最上面1张卡。"
		op=1
	else
		-- 否则（只有场上有可弹回的卡），强制选择“将场上1张卡弹回持有者手牌”的效果
		Duel.SelectOption(tp,aux.Stringid(61587183,1))  --"将场上1张卡弹回持有者手牌。"
		op=0
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择场上1张可以返回手牌的卡作为效果对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置当前连锁的操作信息为：将1张卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else e:SetProperty(0) end
end
-- 效果处理函数，根据选择的分支执行对应的效果
function c61587183.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取在发动时选择的效果对象
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标卡片送回持有者手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	else
		-- 获取对方卡组最上面的一张卡
		local g=Duel.GetDecktopGroup(1-tp,1)
		if g:GetCount()>0 then
			-- 让发动效果的玩家确认（检视）这张卡
			Duel.ConfirmCards(tp,g)
			-- 提示玩家选择卡片放置的位置
			Duel.Hint(HINT_SELECTMSG,tp,0)
			-- 让玩家选择将卡片放回卡组最上面还是最下面
			local ac=Duel.SelectOption(tp,aux.Stringid(61587183,3),aux.Stringid(61587183,4))  --"放回卡组最上面/放回卡组最下面"
			-- 如果玩家选择放回最下面，则将该卡移动到卡组最下方
			if ac==1 then Duel.MoveSequence(g:GetFirst(),SEQ_DECKBOTTOM) end
		end
	end
end

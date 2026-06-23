--黒蠍－強力のゴーグ
-- 效果：
-- 这张卡对对方造成战斗伤害时，可以从下列效果中选择1项发动：
-- ●将对方场上1张怪兽卡弹回对方卡组最上面。
-- ●将对方卡组最上面1张卡送去墓地。
function c48768179.initial_effect(c)
	-- 创建一个诱发选发效果，当这张卡对对方造成战斗伤害时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48768179,0))  --"选择一个效果发动"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c48768179.condition)
	e1:SetTarget(c48768179.target)
	e1:SetOperation(c48768179.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：造成战斗伤害的玩家不是控制者
function c48768179.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果处理：判断是否可以发动效果，检查对方卡组能否送去墓地或对方场上是否有怪兽卡能送回卡组
function c48768179.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 检查对方玩家是否可以将卡组最上面1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1)
		-- 检查对方场上是否存在可送回卡组的怪兽卡
		or Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	local op=0
	-- 提示玩家选择发动哪个效果
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48768179,0))  --"选择一个效果发动"
	-- 判断对方场上是否存在可送回卡组的怪兽卡
	if Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil)
		-- 同时满足对方卡组能送去墓地和对方场上存在可送回卡组的怪兽卡
		and Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		-- 让玩家在两个效果中选择一个，选项1为将对方场上怪兽卡弹回对方卡组最上面，选项2为将对方卡组最上面1张卡送去墓地
		op=Duel.SelectOption(tp,aux.Stringid(48768179,1),aux.Stringid(48768179,2))  --"将对方场上1张怪兽卡弹回对方牌组最上面。/将对方牌组最上面1张卡送去墓地。"
	-- 如果只有对方卡组能送去墓地的情况
	elseif Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		-- 提示玩家选择发动效果2（将对方卡组最上面1张卡送去墓地）
		Duel.SelectOption(tp,aux.Stringid(48768179,2))  --"将对方牌组最上面1张卡送去墓地。"
		op=1
	else
		-- 提示玩家选择发动效果1（将对方场上怪兽卡弹回对方卡组最上面）
		Duel.SelectOption(tp,aux.Stringid(48768179,1))  --"将对方场上1张怪兽卡弹回对方牌组最上面。"
		op=0
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要送回卡组的怪兽卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择对方场上1张可送回卡组的怪兽卡作为对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息为将选中的怪兽卡送回对方卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		-- 设置操作信息为将对方卡组最上面1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
		e:SetProperty(0)
	end
end
-- 效果处理：根据选择的效果执行对应的操作，若选择效果1则将对象怪兽卡弹回对方卡组最上面，若选择效果2则将对方卡组最上面1张卡送去墓地
function c48768179.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁中被选中的目标怪兽卡
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标怪兽卡以效果原因送回对方卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	else
		-- 将对方卡组最上面1张卡以效果原因送去墓地
		Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
	end
end

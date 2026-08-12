--黒蠍－罠はずしのクリフ
-- 效果：
-- ①：这张卡给与对方战斗伤害时，可以从以下效果选择1个发动。
-- ●以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ●从对方卡组上面把2张卡送去墓地。
function c6967870.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害时，可以从以下效果选择1个发动。●以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。●从对方卡组上面把2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6967870,0))  --"选择一个效果发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c6967870.condition)
	e1:SetTarget(c6967870.target)
	e1:SetOperation(c6967870.operation)
	c:RegisterEffect(e1)
end
-- 判定给与对方玩家战斗伤害（受到伤害的玩家ep不等于发动效果的玩家tp）
function c6967870.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤场上的魔法、陷阱卡
function c6967870.filter(c)
	return c:IsType(TYPE_TRAP+TYPE_SPELL)
end
-- 效果①的发动准备与对象选择函数，处理分支效果的合法性判定与玩家选择
function c6967870.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c6967870.filter(chkc) end
	-- 在chk==0（检查是否能发动）时，检查是否能执行将对方卡组最上方2张卡送去墓地的效果
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,2)
		-- 或者检查场上是否存在可以作为对象的魔法·陷阱卡
		or Duel.IsExistingTarget(c6967870.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local op=0
	-- 如果场上存在可以作为对象的魔法·陷阱卡
	if Duel.IsExistingTarget(c6967870.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 并且可以执行将对方卡组最上方2张卡送去墓地的效果
		and Duel.IsPlayerCanDiscardDeck(1-tp,2) then
		-- 两个效果均可发动时，让玩家选择其中一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(6967870,1),aux.Stringid(6967870,2))  --"破坏场上1张魔法或陷阱卡。/将对方牌组最上面2张卡送去墓地。"
	-- 否则，如果仅能执行将对方卡组最上方2张卡送去墓地的效果
	elseif Duel.IsPlayerCanDiscardDeck(1-tp,2) then
		-- 强制选择将对方卡组最上方2张卡送去墓地的效果
		Duel.SelectOption(tp,aux.Stringid(6967870,2))  --"将对方牌组最上面2张卡送去墓地。"
		op=1
	else
		-- 强制选择破坏场上1张魔法·陷阱卡的效果
		Duel.SelectOption(tp,aux.Stringid(6967870,1))  --"破坏场上1张魔法或陷阱卡。"
		op=0
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张魔法·陷阱卡作为效果的对象
		local g=Duel.SelectTarget(tp,c6967870.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置效果处理信息，包含破坏1张卡的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		-- 设置效果处理信息，包含将对方卡组送去墓地的操作
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
		e:SetProperty(0)
	end
end
-- 效果①的具体效果处理函数，根据玩家的选择执行对应的破坏或送墓效果
function c6967870.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取在发动时选择的作为对象的卡片
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将作为对象的卡片因效果破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 将对方卡组最上方的2张卡送去墓地
		Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	end
end

--本陣強襲
-- 效果：
-- 选择自己场上存在的1只怪兽发动。选择的卡破坏，之后，对方卡组最上面的2张卡送去墓地。
function c62633180.initial_effect(c)
	-- 选择自己场上存在的1只怪兽发动。选择的卡破坏，之后，对方卡组最上面的2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c62633180.target)
	e1:SetOperation(c62633180.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与处理信息设置（检查是否满足发动条件、选择自己场上的1只怪兽作为对象、设置破坏和卡组送墓的操作信息）
function c62633180.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 在发动效果的准备阶段，检查自己场上是否存在至少1只可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择自己场上的1只怪兽作为该效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果包含破坏该怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息，表明此效果包含将对方卡组最上方的2张卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
-- 效果处理的执行（破坏作为对象的怪兽，成功破坏后将对方卡组最上方的2张卡送去墓地）
function c62633180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽在效果处理时仍有效，并将其因效果破坏，若成功破坏则继续执行后续效果
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断效果处理，使前后的破坏与送墓不视为同时发生（对应“之后”的时点）
		Duel.BreakEffect()
		-- 将对方卡组最上方的2张卡送去墓地
		Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	end
end

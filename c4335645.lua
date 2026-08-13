--ニュードリュア
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
function c4335645.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4335645,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c4335645.condition)
	e1:SetTarget(c4335645.target)
	e1:SetOperation(c4335645.operation)
	c:RegisterEffect(e1)
end
-- 诱发必发效果的条件：效果持有者（这张卡）位于墓地，且是由于战斗破坏被送去墓地。
function c4335645.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 发动时的目标处理：无对象时直接通过；有对象候选时校验对象位于主要怪兽区；然后提示选择并选择场上1只怪兽，设置对应的破坏操作信息。
function c4335645.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方主要怪兽区的1只怪兽作为效果对象（不限定具体条件）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的处理信息设置为破坏，目标为已选择的怪兽，数量为1，向系统声明此效果将进行破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：取出效果对象，若对象仍与此效果关联（未离场或未失效），则将其破坏。
function c4335645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该怪兽（送入墓地）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

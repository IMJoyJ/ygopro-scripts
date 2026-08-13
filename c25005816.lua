--鼓舞
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升700。
function c25005816.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为不在伤害步骤或伤害计算前，防止在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c25005816.target)
	e1:SetOperation(c25005816.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标选择处理：检查自己场上是否有表侧表示怪兽，并让玩家选择1只作为对象。
function c25005816.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动合法性检查：确认自己场上存在至少1只表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从自己场上选择1只表侧表示怪兽，并设为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果关联且表侧表示，则给它附加攻击力上升700的效果，直到回合结束时适用。
function c25005816.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end

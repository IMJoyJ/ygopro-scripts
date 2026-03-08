--ニュードリュア
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
function c4335645.initial_effect(c)
	-- 效果原文内容：①：这张卡被战斗破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
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
-- 规则层面操作：判断此卡是否因战斗破坏而送去墓地
function c4335645.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面操作：选择场上一只怪兽作为破坏对象
function c4335645.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 规则层面操作：向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面操作：选择目标怪兽，数量为1
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面操作：设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行破坏效果，将选中的怪兽破坏
function c4335645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--暗黒界の刺客 カーキ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
function c25847467.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25847467,0))  --"把场上1只怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c25847467.descon)
	e1:SetTarget(c25847467.destg)
	e1:SetOperation(c25847467.desop)
	c:RegisterEffect(e1)
end
-- 发动条件：此卡被效果从手牌丢弃去墓地（此前位于手牌，且送去墓地的原因为效果丢弃）。
function c25847467.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 目标选择与操作信息设置：若检查对象，要求对象位于怪兽区域；发动时直接允许发动，选择场上1只怪兽作为对象，并写入破坏的操作信息。
function c25847467.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区域选择1只怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 为当前连锁设置破坏效果的操作信息，指明将破坏所选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得对象怪兽，若其仍与该效果关联，则将其破坏。
function c25847467.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

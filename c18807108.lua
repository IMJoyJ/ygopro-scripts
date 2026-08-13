--六芒星の呪縛
-- 效果：
-- 选择对方场上存在的1只怪兽发动。选择的怪兽不能攻击，也不能把表示形式变更。选择的怪兽破坏时，这张卡破坏。
function c18807108.initial_effect(c)
	-- 选择对方场上存在的1只怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c18807108.target)
	e1:SetOperation(c18807108.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽破坏时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c18807108.descon)
	e2:SetOperation(c18807108.desop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	-- 也不能把表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
end
-- 发动时的对象选择处理：先核实指定对象必须是对方场上怪兽区的怪兽，再确认是否有合法对象，若有则提示玩家并从中选择1只作为效果对象。
function c18807108.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果发动前检查：确认对方场上是否至少存在1只可以成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择卡片的消息提示，提示文本为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择1只怪兽作为效果对象，并将选中的卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时：若这张卡和对象怪兽均与效果保持关联，则将对象怪兽设为这张卡的永续对象，使其持续受到本卡的限制。
function c18807108.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 自毁触发条件的判定：这张卡未被预定破坏，且场上存在通过本卡设定的永续对象怪兽，并且该怪兽因被破坏而离场。
function c18807108.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 自毁效果的处理：满足条件时，将这张卡本身破坏。
function c18807108.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡送去墓地（即破坏）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

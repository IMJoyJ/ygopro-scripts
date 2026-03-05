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
	-- 选择的怪兽不能把表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
end
-- 检索满足条件的怪兽组
function c18807108.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上的怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将选择的怪兽设置为当前卡的效果对象
function c18807108.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断目标怪兽是否因破坏而离场
function c18807108.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当满足条件时，将自身破坏
function c18807108.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身以效果原因破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

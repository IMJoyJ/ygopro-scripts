--ドリーム・ピエロ
-- 效果：
-- 这张卡的表示形式从攻击表示变成守备表示时，破坏对方场上的1只怪兽。
function c13215230.initial_effect(c)
	-- 这张卡的表示形式从攻击表示变成守备表示时，破坏对方场上的1只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13215230,0))  --"破坏对方场上1只怪兽"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c13215230.condition)
	e1:SetTarget(c13215230.target)
	e1:SetOperation(c13215230.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在表示形式变更前是攻击表示，且变更后为表侧守备表示，即“这张卡的表示形式从攻击表示变成守备表示时”。
function c13215230.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_ATTACK) and c:IsFaceup() and c:IsDefensePos()
end
-- 发动时选择对方场上1只怪兽作为对象，并设置将予以破坏的操作信息。
function c13215230.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向操作者发出选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象（不取对象限制以外的任意表侧或里侧怪兽均可）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将当前连锁的操作信息登记为破坏效果：对象为已选择的那只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：若对象仍与效果相关，则将其破坏，对应“破坏对方场上的1只怪兽”。
function c13215230.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将那只对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

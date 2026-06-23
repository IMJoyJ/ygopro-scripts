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
-- 判断表示形式变更是否满足效果发动条件
function c13215230.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_ATTACK) and c:IsFaceup() and c:IsDefensePos()
end
-- 选择破坏对象
function c13215230.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向玩家提示选择破坏对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理效果的破坏操作
function c13215230.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

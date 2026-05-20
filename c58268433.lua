--ブレードラビット
-- 效果：
-- 这张卡的表示形式从攻击表示变成表侧守备表示时，破坏对方场上1只怪兽。
function c58268433.initial_effect(c)
	-- 这张卡的表示形式从攻击表示变成表侧守备表示时，破坏对方场上1只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58268433,0))  --"破坏对方场上1只怪兽"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c58268433.condition)
	e1:SetTarget(c58268433.target)
	e1:SetOperation(c58268433.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否从攻击表示变为了表侧守备表示，以此作为效果发动的条件
function c58268433.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_ATTACK) and c:IsFaceup() and c:IsDefensePos()
end
-- 效果发动的目标选择，进行取对象检测并设置破坏的操作信息
function c58268433.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 给发动效果的玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为取对象的效果目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理是破坏所选的对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，获取并破坏作为效果对象的怪兽
function c58268433.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

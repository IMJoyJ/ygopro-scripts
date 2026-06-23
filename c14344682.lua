--サムライソード・バロン
-- 效果：
-- 1回合1次，选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。
function c14344682.initial_effect(c)
	-- 1回合1次，选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14344682,0))  --"表示形式改变"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c14344682.target)
	e1:SetOperation(c14344682.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时的Target函数定义
function c14344682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	-- 检查是否满足选择目标的条件，即对方场上是否存在守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)
	-- 选择对方场上1只守备表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时的操作信息，指定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时的Operation函数定义
function c14344682.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果所选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsDefensePos() then
		-- 将目标怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end

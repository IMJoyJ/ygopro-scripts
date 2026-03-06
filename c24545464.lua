--シンクロン・リフレクト
-- 效果：
-- 自己场上表侧表示存在的同调怪兽成为攻击对象时才能发动。那个攻击无效，对方场上存在的1只怪兽破坏。
function c24545464.initial_effect(c)
	-- 创建效果对象并设置其分类为破坏、类型为发动、属性为取对象、触发时点为被选为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c24545464.condition)
	e1:SetTarget(c24545464.target)
	e1:SetOperation(c24545464.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上表侧表示存在的同调怪兽成为攻击对象时
function c24545464.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsType(TYPE_SYNCHRO)
end
-- 选择目标：对方场上1只怪兽作为破坏对象
function c24545464.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否满足选择目标的条件：对方场上存在1只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：无效攻击并破坏对方场上1只怪兽
function c24545464.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
	-- 获取当前连锁的破坏目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

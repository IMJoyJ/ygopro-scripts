--ヘイト・クレバス
-- 效果：
-- 自己场上存在的怪兽1只被对方的卡的效果破坏送去墓地时，选择对方场上存在的1只怪兽送去墓地，给与对方基本分那个原本攻击力数值的伤害。
function c20721759.initial_effect(c)
	-- 创建效果，设置效果类别为送去墓地和伤害，类型为发动效果，属性为取对象效果，触发事件为送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c20721759.condition)
	e1:SetTarget(c20721759.target)
	e1:SetOperation(c20721759.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断：对方破坏自己场上怪兽送去墓地
function c20721759.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return rp==1-tp and eg:GetCount()==1 and ec:IsPreviousLocation(LOCATION_MZONE) and ec:IsPreviousControler(tp)
		and ec:IsReason(REASON_DESTROY) and ec:IsReason(REASON_EFFECT)
end
-- 选择对方场上怪兽作为效果对象并设置操作信息
function c20721759.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选择的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置操作信息：对对方造成该怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 效果处理函数，将目标怪兽送去墓地并造成伤害
function c20721759.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽以效果原因送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
	if not tc:IsLocation(LOCATION_GRAVE) then return end
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 对对方造成目标怪兽原本攻击力数值的伤害
	Duel.Damage(1-tp,atk,REASON_EFFECT)
end

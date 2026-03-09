--インフォーマー・スパイダー
-- 效果：
-- 场上存在的这张卡被卡的效果送去墓地时，得到对方场上守备表示存在的1只怪兽的控制权。
function c4941482.initial_effect(c)
	-- 诱发必发效果，满足条件时发动
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetDescription(aux.Stringid(4941482,0))  --"获得控制权"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c4941482.condition)
	e2:SetTarget(c4941482.target)
	e2:SetOperation(c4941482.operation)
	c:RegisterEffect(e2)
end
-- 场上存在的这张卡被卡的效果送去墓地时
function c4941482.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 筛选对方场上守备表示存在的怪兽
function c4941482.filter(c)
	return c:IsDefensePos() and c:IsControlerCanBeChanged()
end
-- 选择对方场上一只守备表示怪兽作为目标
function c4941482.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c4941482.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选取符合条件的目标怪兽
	local g=Duel.SelectTarget(tp,c4941482.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 将目标怪兽的控制权转移给发动者
function c4941482.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽获得发动者的控制权
		Duel.GetControl(tc,tp)
	end
end

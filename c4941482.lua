--インフォーマー・スパイダー
-- 效果：
-- 场上存在的这张卡被卡的效果送去墓地时，得到对方场上守备表示存在的1只怪兽的控制权。
function c4941482.initial_effect(c)
	-- 场上存在的这张卡被卡的效果送去墓地时，得到对方场上守备表示存在的1只怪兽的控制权。
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
-- 检查触发条件：此卡在场上被卡的效果送去墓地时，本效果才满足发动条件。
function c4941482.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 筛选条件：对方场上的怪兽必须是守备表示，且其控制权可以被改变。
function c4941482.filter(c)
	return c:IsDefensePos() and c:IsControlerCanBeChanged()
end
-- 发动时的目标处理：选择对方场上1只符合条件的守备表示怪兽作为对象，并设置操作信息。
function c4941482.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c4941482.filter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示选择提示“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上（LOCATION_MZONE）选择1只满足c4941482.filter的怪兽作为效果对象，数量为1。
	local g=Duel.SelectTarget(tp,c4941482.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为改变控制权（CATEGORY_CONTROL），以便后续效果处理及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：取得选择的对象，若对象仍在场上且为守备表示并与本效果有联系，则将其控制权转移。
function c4941482.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的首个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给效果发动者tp。
		Duel.GetControl(tc,tp)
	end
end

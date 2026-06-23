--心変わり
-- 效果：
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c4031928.initial_effect(c)
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c4031928.target)
	e1:SetOperation(c4031928.activate)
	c:RegisterEffect(e1)
end
-- 选择对方场上的1只可以改变控制权的怪兽作为对象
function c4031928.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，记录将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 将目标怪兽的控制权直到结束阶段得到
function c4031928.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给发动玩家，持续到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

--心変わり
-- 效果：
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c4031928.initial_effect(c)
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。（对应效果创建及注册：设置类别为改变控制权、类型为魔陷发动、取对象、自由时点，并指定目标与处理子函数后注册给本体）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c4031928.target)
	e1:SetOperation(c4031928.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标处理：检查对方场上有可改变控制权的怪兽，选择其中1只作为对象，并设置改变控制权的操作信息。
function c4031928.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 发动合法性检查：确认对方场上有1只以上可被改变控制权的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可改变控制权的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将改变1只怪兽的控制权（category为CATEGORY_CONTROL）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：取得作为对象的怪兽，若其仍与效果关联，则获得其控制权直到结束阶段。
function c4031928.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第1个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让当前玩家获得该怪兽控制权，直到结束阶段时归还（PHASE_END，持续1次）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

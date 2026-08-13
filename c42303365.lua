--レプティレス・バイパー
-- 效果：
-- ①：这张卡召唤成功时，以对方场上1只攻击力0的怪兽为对象才能发动。得到那只攻击力0的怪兽的控制权。
function c42303365.initial_effect(c)
	-- ①：这张卡召唤成功时，以对方场上1只攻击力0的怪兽为对象才能发动。得到那只攻击力0的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42303365,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetTarget(c42303365.ctltg)
	e1:SetOperation(c42303365.ctlop)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的怪兽：对象必须是表侧表示、攻击力为0，并且控制权能够被改变。
function c42303365.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsAttack(0)
end
-- 效果的发动条件与目标选取：发动时确认对方场上存在攻击力0且可改变控制权的怪兽，让玩家选择其中1只作为对象，并记录该改变控制权的操作信息。
function c42303365.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c42303365.filter(chkc) end
	-- 在效果发动前的合法性检查中，确认对方场上是否存在至少1只符合条件的攻击力0表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c42303365.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变控制权的怪兽”的提示，引导玩家进行目标选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 在对方场上主要怪兽区域选择1只符合条件的怪兽作为效果对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c42303365.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：这是一个改变控制权的效果，处理对象为已选择的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时的操作：获取对象怪兽，若它仍与效果相关联、仍表侧表示且攻击力仍为0，则取得其控制权。
function c42303365.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那只攻击力为0的对方怪兽作为目标。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttack(0) then
		-- 将目标怪兽的控制权转移给本效果的发动者，完成取得控制权的处理。
		Duel.GetControl(tc,tp)
	end
end

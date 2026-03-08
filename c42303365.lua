--レプティレス・バイパー
-- 效果：
-- ①：这张卡召唤成功时，以对方场上1只攻击力0的怪兽为对象才能发动。得到那只攻击力0的怪兽的控制权。
function c42303365.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时，以对方场上1只攻击力0的怪兽为对象才能发动。得到那只攻击力0的怪兽的控制权。
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
-- 检索满足条件的怪兽（表侧表示、控制权可改变、攻击力为0）
function c42303365.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsAttack(0)
end
-- 效果作用：选择对方场上一只攻击力为0的怪兽作为对象
function c42303365.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c42303365.filter(chkc) end
	-- 判断是否满足发动条件（对方场上是否存在攻击力为0的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c42303365.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一只对方场上的攻击力为0的怪兽作为对象
	local g=Duel.SelectTarget(tp,c42303365.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果作用：将选定的怪兽控制权转移给发动者
function c42303365.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttack(0) then
		-- 将对象怪兽的控制权转移给发动者
		Duel.GetControl(tc,tp)
	end
end

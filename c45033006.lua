--A・O・J エネミー・キャッチャー
-- 效果：
-- 这张卡召唤成功时，直到这个回合的结束阶段时可以得到对方场上里侧守备表示存在的1只怪兽的控制权。
function c45033006.initial_effect(c)
	-- 这张卡召唤成功时，直到这个回合的结束阶段时可以得到对方场上里侧守备表示存在的1只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45033006,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45033006.target)
	e1:SetOperation(c45033006.operation)
	c:RegisterEffect(e1)
end
-- 定义可选对象过滤条件：必须是里侧守备表示且控制权可以被改变的怪兽。
function c45033006.filter(c)
	return c:IsFacedown() and c:IsDefensePos() and c:IsControlerCanBeChanged()
end
-- 发动时的目标选择处理：确认对象为对方场上的里侧守备表示怪兽，并选择其中1只作为效果对象。
function c45033006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45033006.filter(chkc) end
	-- 发动时点检查：确认对方场上是否存在1只以上符合过滤条件的里侧守备表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c45033006.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家弹出选择提示，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 在对方主要怪兽区选择1只满足条件的里侧守备表示怪兽，并将其登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c45033006.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，声明本次处理将改变1只怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时的操作：取得连锁对象，若该对象仍与效果相关且仍为里侧守备表示，则改变其控制权。
function c45033006.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsDefensePos() then
		-- 获得该怪兽的控制权，持续到结束阶段（即直到第1次结束阶段时归还）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

--幻惑のラフレシア
-- 效果：
-- 反转：直到回合结束前，得到对方场上的1只表侧表示的怪兽的控制权。
function c31440542.initial_effect(c)
	-- 反转：直到回合结束前，得到对方场上的1只表侧表示的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31440542,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c31440542.ctltg)
	e1:SetOperation(c31440542.ctlop)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，筛选出表侧表示且可以变更控制权的对方怪兽。
function c31440542.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 目标选择函数：确认对象必须是对方场上表侧表示且可变更控制权的怪兽；发动时选择1只符合条件的对方怪兽作为效果对象，并设置操作信息。
function c31440542.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31440542.filter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示“请选择要改变控制权的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方主要怪兽区选择1只满足过滤条件的表侧表示怪兽，并将其登记为效果的对象。
	local g=Duel.SelectTarget(tp,c31440542.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息为改变控制权，目标组为已选择的怪兽，数量为其数量，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理函数：取得效果对象，若对象仍与效果相关且为表侧表示，则获得其控制权。
function c31440542.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽的控制权转移给效果发动者，持续到结束阶段（PHASE_END）的第1次到来为止。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

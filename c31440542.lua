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
-- 筛选满足条件的怪兽（表侧表示且可以改变控制权）
function c31440542.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 设置效果目标为对方场上的1只表侧表示的怪兽
function c31440542.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31440542.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c31440542.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为改变控制权效果
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 处理效果发动，将目标怪兽的控制权转移给使用者
function c31440542.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的控制权转移给使用者直到回合结束
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

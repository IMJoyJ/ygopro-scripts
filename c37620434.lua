--デーモン・テイマー
-- 效果：
-- 反转：在回合结束前得到对方场上的1只表侧表示存在的恶魔族怪兽。
function c37620434.initial_effect(c)
	-- 反转：在回合结束前得到对方场上的1只表侧表示存在的恶魔族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37620434,0))  --"控制权转移"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37620434.target)
	e1:SetOperation(c37620434.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽：表侧表示、恶魔族、可以改变控制权
function c37620434.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAbleToChangeControler()
end
-- 设置效果目标：选择对方场上1只满足条件的怪兽
function c37620434.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37620434.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c37620434.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：将目标怪兽的控制权转移给发动者直到回合结束
function c37620434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FIEND) then
		-- 将目标怪兽的控制权转移给发动者，持续到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

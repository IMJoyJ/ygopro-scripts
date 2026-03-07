--強制転移
-- 效果：
-- ①：双方玩家各自选自身场上1只怪兽。那2只怪兽的控制权交换。这个回合，那些怪兽不能把表示形式变更。
function c31036355.initial_effect(c)
	-- 效果原文内容：①：双方玩家各自选自身场上1只怪兽。那2只怪兽的控制权交换。这个回合，那些怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31036355.target)
	e1:SetOperation(c31036355.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽组，条件为可以改变控制权且该玩家场上存在可用怪兽区
function c31036355.filter(c)
	local tp=c:GetControler()
	-- 返回值为该怪兽是否可以改变控制权且该玩家场上存在可用怪兽区
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 判断是否满足发动条件，即双方场上各存在至少1只可以交换控制权的怪兽
function c31036355.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31036355.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c31036355.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置连锁处理信息，表示该效果属于改变控制权类别
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
-- 判断是否满足发动条件，即双方场上各存在至少1只可以交换控制权的怪兽
function c31036355.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己场上是否存在满足条件的怪兽
	if not Duel.IsExistingMatchingCard(c31036355.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在满足条件的怪兽
		or not Duel.IsExistingMatchingCard(c31036355.filter,tp,0,LOCATION_MZONE,1,nil)
	then return end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的怪兽作为第一只目标怪兽
	local g1=Duel.SelectMatchingCard(tp,c31036355.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示第一只目标怪兽被选中的动画效果
	Duel.HintSelection(g1)
	-- 向对方提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的怪兽作为第二只目标怪兽
	local g2=Duel.SelectMatchingCard(1-tp,c31036355.filter,1-tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示第二只目标怪兽被选中的动画效果
	Duel.HintSelection(g2)
	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	-- 交换两只目标怪兽的控制权
	if Duel.SwapControl(c1,c2,0,0) then
		-- 效果原文内容：①：双方玩家各自选自身场上1只怪兽。那2只怪兽的控制权交换。这个回合，那些怪兽不能把表示形式变更。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_PHASE+PHASE_END)
		c1:RegisterEffect(e1)
		local e2=e1:Clone()
		c2:RegisterEffect(e2)
	end
end

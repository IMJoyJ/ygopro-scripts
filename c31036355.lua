--強制転移
-- 效果：
-- ①：双方玩家各自选自身场上1只怪兽。那2只怪兽的控制权交换。这个回合，那些怪兽不能把表示形式变更。
function c31036355.initial_effect(c)
	-- ①：双方玩家各自选自身场上1只怪兽。那2只怪兽的控制权交换。这个回合，那些怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31036355.target)
	e1:SetOperation(c31036355.activate)
	c:RegisterEffect(e1)
end
-- 定义“可被选择/交换控制权”的怪兽过滤条件：该怪兽能够改变控制权，且其控制者在该怪兽离场后仍有空的怪兽区可用，保证交换后能接收对方怪兽。
function c31036355.filter(c)
	local tp=c:GetControler()
	-- 怪兽必须满足以下两点：可以改变控制权；其控制者在这个怪兽离开后有至少1个空闲怪兽区，以容纳交换过来的对方怪兽。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果发动时的合法性判定与目标选择函数：确认双方场上都各自存在符合条件的怪兽，从而允许发动并登记控制权交换。
function c31036355.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，先确认我方场上存在至少1只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31036355.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认对方场上也存在至少1只符合条件的怪兽，保证双方都有可交换对象。
		and Duel.IsExistingMatchingCard(c31036355.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 登记本连锁的处理信息为改变控制权效果，因具体交换对象在效果处理时才由双方选择，所以目标和数量留空/为0。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
-- 效果处理时先复核双方场上是否仍各有符合条件且能交换的怪兽；若任一方不满足则这次效果不处理。
function c31036355.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若我方场上的符合条件怪兽不存在，说明不能交换，直接终止效果处理。
	if not Duel.IsExistingMatchingCard(c31036355.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 若对方场上的符合条件怪兽不存在，同样无法交换，直接终止效果处理。
		or not Duel.IsExistingMatchingCard(c31036355.filter,tp,0,LOCATION_MZONE,1,nil)
	then return end
	-- 向当前玩家发出选择提示，使用预设文本‘请选择要改变控制权的怪兽’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让当前玩家从自己场上选取1只符合条件的怪兽，作为我方要交换控制权的对象。
	local g1=Duel.SelectMatchingCard(tp,c31036355.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将我方选中的怪兽做出被选为对象的动画提示，并记录为该连锁的对象。
	Duel.HintSelection(g1)
	-- 向对方玩家发出选择提示，使用预设文本‘请选择要改变控制权的怪兽’。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让对方玩家从自己场上选取1只符合条件的怪兽，作为对方要交换控制权的对象。
	local g2=Duel.SelectMatchingCard(1-tp,c31036355.filter,1-tp,LOCATION_MZONE,0,1,1,nil)
	-- 将对方选中的怪兽做出被选为对象的动画提示，并记录为该连锁的对象。
	Duel.HintSelection(g2)
	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	-- 执行双方所选怪兽的控制权交换；若交换成功（返回真），则继续给这两只怪兽附加本回合不能变更表示形式的效果。
	if Duel.SwapControl(c1,c2,0,0) then
		-- 这个回合，那些怪兽不能把表示形式变更。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_PHASE+PHASE_END)
		c1:RegisterEffect(e1)
		local e2=e1:Clone()
		c2:RegisterEffect(e2)
	end
end

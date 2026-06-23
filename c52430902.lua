--サイコジャンパー
-- 效果：
-- 支付1000基本分并选择对方场上表侧表示存在的1只怪兽，那只怪兽和「念力跳跃者」以外的自己场上表侧表示存在的1只念动力族怪兽的控制权交换。选择的怪兽在这个回合不能作表示形式的改变。这个效果1回合只能使用1次。
function c52430902.initial_effect(c)
	-- 支付1000基本分并选择对方场上表侧表示存在的1只怪兽，那只怪兽和「念力跳跃者」以外的自己场上表侧表示存在的1只念动力族怪兽的控制权交换。选择的怪兽在这个回合不能作表示形式的改变。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52430902,0))  --"交换控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c52430902.cost)
	e1:SetTarget(c52430902.target)
	e1:SetOperation(c52430902.operation)
	c:RegisterEffect(e1)
end
-- 检查玩家是否能支付1000基本分
function c52430902.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 筛选自己场上表侧表示存在的念动力族怪兽（排除自身）且能改变控制权的怪兽
function c52430902.filter1(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsCode(52430902)
		-- 确保目标怪兽能改变控制权且自己场上存在可用怪兽区
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 筛选自己场上表侧表示存在的能改变控制权的怪兽
function c52430902.filter2(c)
	local tp=c:GetControler()
	-- 确保目标怪兽能改变控制权且自己场上存在可用怪兽区
	return c:IsFaceup() and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 判断是否满足选择目标的条件，即对方场上存在可选怪兽和己方场上存在符合条件的念动力族怪兽
function c52430902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断对方场上是否存在满足filter2条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c52430902.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 判断己方场上是否存在满足filter1条件的念动力族怪兽
		and Duel.IsExistingTarget(c52430902.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足filter1条件的己方怪兽作为目标
	local g1=Duel.SelectTarget(tp,c52430902.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家发送提示信息“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足filter2条件的对方怪兽作为目标
	local g2=Duel.SelectTarget(tp,c52430902.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时将要交换控制权的怪兽数量为2
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 执行控制权交换和表示形式改变限制效果
function c52430902.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
		-- 交换两个目标怪兽的控制权
		if Duel.SwapControl(tc1,tc2) then
			-- 为交换控制权的怪兽添加不能改变表示形式的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc1:RegisterEffect(e1)
			local e2=e1:Clone()
			tc2:RegisterEffect(e2)
		end
	end
end

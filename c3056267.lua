--王座の侵略者
-- 效果：
-- 反转：选择对方场上存在的1只怪兽，那只怪兽和这张卡的控制权交换。这个效果在战斗阶段不能发动。
function c3056267.initial_effect(c)
	-- 反转：选择对方场上存在的1只怪兽，那只怪兽和这张卡的控制权交换。这个效果在战斗阶段不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3056267,0))  --"交换控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCondition(c3056267.condition)
	e1:SetTarget(c3056267.target)
	e1:SetOperation(c3056267.operation)
	c:RegisterEffect(e1)
end
-- 用于筛选可以交换控制权的怪兽，确保目标怪兽能够改变控制权且对方有可用怪兽区。
function c3056267.swapfilter(c)
	local tp=c:GetControler()
	-- 检查目标怪兽是否可以改变控制权，并且目标玩家在该怪兽离开后仍有可用怪兽区。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 检查当前阶段是否为战斗阶段，若为战斗阶段则效果不能发动。
function c3056267.condition(e)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 设置效果的目标，选择对方场上满足条件的怪兽作为交换对象。
function c3056267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 检查己方是否有可用怪兽区，用于后续交换控制权操作。
	if Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在满足交换条件的怪兽。
		and Duel.IsExistingTarget(c3056267.swapfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 提示玩家选择要改变控制权的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上满足条件的1只怪兽作为目标。
		local mon=Duel.SelectTarget(tp,c3056267.swapfilter,tp,0,LOCATION_MZONE,1,1,nil)
		mon:AddCard(e:GetHandler())
		-- 设置效果操作信息，标记本次效果将交换控制权。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,mon,2,0,0)
	end
end
-- 执行效果操作，交换控制权。
function c3056267.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		-- 交换控制权，将己方怪兽与目标怪兽的控制权进行互换。
		Duel.SwapControl(c,tc)
	end
end

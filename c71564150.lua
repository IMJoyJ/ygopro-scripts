--地獄の傀儡魔人
-- 效果：
-- 1回合1次，可以丢弃1张手卡，对方场上表侧表示存在的全部3星以下的怪兽的控制权直到结束阶段时得到。这个效果得到控制权的怪兽不能把效果发动，也不能解放和作为同调素材。
function c71564150.initial_effect(c)
	-- 1回合1次，可以丢弃1张手卡，对方场上表侧表示存在的全部3星以下的怪兽的控制权直到结束阶段时得到。这个效果得到控制权的怪兽不能把效果发动，也不能解放和作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c71564150.cost)
	e1:SetTarget(c71564150.target)
	e1:SetOperation(c71564150.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价，检查并丢弃手卡
function c71564150.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡中选择1张卡丢弃作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选对方场上表侧表示、等级3以下且可以转移控制权的怪兽
function c71564150.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged()
end
-- 定义效果的发动准备，检查对方场上是否存在符合条件的怪兽并设置操作信息
function c71564150.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查对方场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71564150.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置效果处理的操作信息为转移对方场上怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 定义效果的实际处理，获取符合条件的怪兽控制权并施加限制
function c71564150.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local c=e:GetHandler()
	-- 提示玩家选择要转移控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择数量不超过自己场上空位数量的、符合条件的对方怪兽
	local g=Duel.SelectMatchingCard(tp,c71564150.filter,tp,0,LOCATION_MZONE,ft,ft,nil)
	-- 直到结束阶段时得到所选怪兽的控制权
	Duel.GetControl(g,tp,PHASE_END,1)
	-- 获取实际成功转移控制权的怪兽卡组
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 这个效果得到控制权的怪兽不能把效果发动，也不能解放和作为同调素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_TRIGGER)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		tc=og:GetNext()
	end
end

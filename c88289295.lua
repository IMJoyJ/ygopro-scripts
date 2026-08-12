--シンクロ・コントロール
-- 效果：
-- 这张卡在自己场上以及自己墓地没有同调怪兽存在的场合才能发动。支付1000基本分，选择对方场上表侧表示存在的1只同调怪兽发动。直到自己的结束阶段时，得到选择的怪兽的控制权。
function c88289295.initial_effect(c)
	-- 这张卡在自己场上以及自己墓地没有同调怪兽存在的场合才能发动。支付1000基本分，选择对方场上表侧表示存在的1只同调怪兽发动。直到自己的结束阶段时，得到选择的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c88289295.condition)
	e1:SetCost(c88289295.cost)
	e1:SetTarget(c88289295.target)
	e1:SetOperation(c88289295.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自己场上及墓地是否存在同调怪兽
function c88289295.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上和墓地是否不存在同调怪兽
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,TYPE_SYNCHRO)
end
-- 发动代价：支付1000基本分
function c88289295.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：选择对方场上表侧表示存在且可以改变控制权的同调怪兽
function c88289295.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsControlerCanBeChanged()
end
-- 发动目标：选择对方场上表侧表示存在的1只同调怪兽为对象
function c88289295.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c88289295.filter(chkc) end
	-- 在发动准备阶段，检查对方场上是否存在符合条件的同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c88289295.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88289295.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果分类为改变控制权，操作对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：直到自己的结束阶段时，得到选择的怪兽的控制权
function c88289295.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	local ct=1
	-- 如果当前不是自己的回合，则将控制权转移的持续时间设为2个结束阶段（即直到自己的结束阶段）
	if Duel.GetTurnPlayer()~=tp then ct=2 end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 让玩家获得目标怪兽的控制权，直到指定的结束阶段
		Duel.GetControl(tc,tp,PHASE_END,ct)
	end
end

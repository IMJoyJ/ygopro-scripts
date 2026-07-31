--亜空間ジャンプ装置
-- 效果：
-- 自己场上1只怪兽和对方场上1只放置有A指示物的怪兽控制权交换。
function c57384901.initial_effect(c)
	-- ①：自己场上1只怪兽和对方场上1只放置有A指示物的怪兽控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c57384901.target)
	e1:SetOperation(c57384901.activate)
	c:RegisterEffect(e1)
end
c57384901.mentioned_counter={
	[0x100e]=true,
}
-- 己方怪兽过滤条件：可改变控制权且对方场上有空余怪兽区域
function c57384901.filter1(c)
	local tp=c:GetControler()
	-- 检查怪兽是否能改变控制权，以及转移控制权后对应玩家怪兽区域是否有空位
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 对方怪兽过滤条件：放置有A指示物、可改变控制权且己方场上有空余怪兽区域
function c57384901.filter2(c)
	local tp=c:GetControler()
	-- 检查怪兽是否放置有A指示物、能否改变控制权，以及转移控制权后对应玩家怪兽区域是否有空位
	return c:GetCounter(0x100e)>0 and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 交换控制权效果准备：选择双方场上各1只满足条件的怪兽为对象并设置操作信息
function c57384901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：对方场上是否存在放置有A指示物且可改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(c57384901.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 发动条件检查：己方场上是否存在可改变控制权的怪兽
		and Duel.IsExistingTarget(c57384901.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示己方玩家选择要改变控制权的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只放置有A指示物的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c57384901.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示己方玩家选择要改变控制权的己方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择己方场上1只怪兽作为对象
	local g1=Duel.SelectTarget(tp,c57384901.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息：交换这2只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 交换控制权效果处理：交换选中的2只怪兽的控制权
function c57384901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选中的对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换2只对象怪兽的控制权
		Duel.SwapControl(a,b)
	end
end

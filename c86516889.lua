--ゴーストリック・パニック
-- 效果：
-- 选择自己场上里侧守备表示存在的怪兽任意数量才能发动。选择的怪兽变成表侧守备表示，选最多有那之中的名字带有「鬼计」的怪兽数量的对方场上表侧表示存在的怪兽变成里侧守备表示。
function c86516889.initial_effect(c)
	-- 选择自己场上里侧守备表示存在的怪兽任意数量才能发动。选择的怪兽变成表侧守备表示，选最多有那之中的名字带有「鬼计」的怪兽数量的对方场上表侧表示存在的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c86516889.target)
	e1:SetOperation(c86516889.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与连锁信息设置
function c86516889.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	-- 检查自己场上是否存在至少1只里侧表示的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择自己场上1到7张里侧表示的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,7,nil)
	-- 设置操作信息，表示此效果包含改变表示形式的操作，操作数量为选中的卡片数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 过滤函数，用于筛选仍处于里侧表示且仍与当前效果相关的对象怪兽
function c86516889.filter(c,e)
	return c:IsFacedown() and c:IsRelateToEffect(e)
end
-- 效果处理的执行函数
function c86516889.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关且仍为里侧表示的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c86516889.filter,nil,e)
	-- 将选中的对象怪兽变成表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	local ct=g:FilterCount(Card.IsSetCard,nil,0x8d)
	if ct>0 then
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择最多等同于其中「鬼计」怪兽数量的对方场上的表侧表示怪兽
		local sg=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,ct,nil)
		if sg:GetCount()>0 then
			-- 为选中的对方怪兽显示被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 将选中的对方怪兽变成里侧守备表示
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end
	end
end

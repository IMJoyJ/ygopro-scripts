--インフェルニティ・ブレイク
-- 效果：
-- 自己手卡是0张的场合才能发动。选择自己墓地存在的1张名字带有「永火」的卡从游戏中除外，选择对方场上存在的1张卡破坏。
function c51717541.initial_effect(c)
	-- 效果定义：永火雷破的发动条件、类型、目标、处理等设置
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c51717541.condition)
	e1:SetTarget(c51717541.target)
	e1:SetOperation(c51717541.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：自己手卡是0张的场合才能发动
function c51717541.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则判断：当前玩家手牌数量为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 过滤器函数：筛选名字带有「永火」且能除外的卡
function c51717541.filter(c)
	return c:IsSetCard(0xb) and c:IsAbleToRemove()
end
-- 选择目标：确认场上和墓地满足条件的目标卡
function c51717541.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 规则判断：对方场上有至少1张卡可破坏
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 规则判断：自己墓地有至少1张名字带有「永火」的卡可除外
		and Duel.IsExistingTarget(c51717541.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示信息：向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标：从自己墓地选择1张名字带有「永火」的卡除外
	local g1=Duel.SelectTarget(tp,c51717541.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示信息：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从对方场上选择1张卡进行破坏
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将要除外的卡加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：将要破坏的卡加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 效果处理函数：执行永火雷破的效果处理
function c51717541.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁相关目标：获取当前连锁中涉及的所有目标卡
	local g=Duel.GetTargetsRelateToChain()
	local rm=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	-- 除外处理：将选中的墓地卡从游戏中除外
	if rm and Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)>0 then
		local ds=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD):GetFirst()
		if ds then
			-- 破坏处理：将选中的对方场上卡进行破坏
			Duel.Destroy(ds,REASON_EFFECT)
		end
	end
end

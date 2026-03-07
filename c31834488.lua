--皆既月蝕の書
-- 效果：
-- ①：丢弃1张手卡，以场上2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
function c31834488.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡，以场上2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetCost(c31834488.poscost)
	e1:SetTarget(c31834488.postg)
	e1:SetOperation(c31834488.posop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否满足丢弃手卡的代价条件
function c31834488.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义选择目标怪兽的过滤条件（必须为表侧表示且可以变为里侧守备表示）
function c31834488.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果作用：设置效果的目标选择逻辑，选择2只符合条件的场上怪兽
function c31834488.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31834488.posfilter(chkc) end
	-- 效果作用：判断场上是否存在2只符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c31834488.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	-- 效果作用：向玩家发送提示信息，提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 效果作用：选择2只符合条件的场上怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c31834488.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	-- 效果作用：设置连锁操作信息，指定将要改变表示形式的怪兽数量为2
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end
-- 效果作用：定义过滤函数，用于筛选与当前效果相关的怪兽（位于怪兽区且存在）
function c31834488.filter(c,e)
	return c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
end
-- 效果作用：执行效果处理，将目标怪兽变为里侧守备表示
function c31834488.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中已选定的目标卡片组，并筛选出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c31834488.filter,nil,e)
	if g:GetCount()>0 then
		-- 效果作用：将符合条件的怪兽变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end

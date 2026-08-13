--皆既月蝕の書
-- 效果：
-- ①：丢弃1张手卡，以场上2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
function c31834488.initial_effect(c)
	-- ①：丢弃1张手卡，以场上2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
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
-- 代价函数整体，用于处理发动时必须丢弃1张手卡：先检查手牌有可丢弃的卡，再执行丢弃。
function c31834488.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：检查自己的手牌中是否存在至少1张可丢弃的手卡（排除发动中的这张卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手牌选择1张可丢弃的卡，以COST+丢弃的理由送去墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象选择过滤条件：怪兽必须是表侧表示且可以变成里侧守备表示。
function c31834488.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 目标函数整体：选择场上2只符合条件的表侧表示怪兽作为效果对象，并登记改变表示形式的操作信息。
function c31834488.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31834488.posfilter(chkc) end
	-- 合法性检查：确认双方怪兽区存在至少2只可作为对象的表侧表示怪兽（且能变为里侧守备）。
	if chk==0 then return Duel.IsExistingTarget(c31834488.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	-- 显示选择提示，让玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家从双方怪兽区选择2只符合条件的表侧表示怪兽，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c31834488.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	-- 登记操作信息：本次连锁将执行变更2只对象怪兽表示形式的效果。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end
-- 效果处理时的对象筛选：选出仍然与该效果相关且还在怪兽区的对象卡（排除中途离场等失效的卡）。
function c31834488.filter(c,e)
	return c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
end
-- 效果处理函数：取出连锁的对象卡，筛选出有效目标后统一变更表示形式。
function c31834488.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象卡组，并过滤出仍然有效且位于怪兽区的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c31834488.filter,nil,e)
	if g:GetCount()>0 then
		-- 将筛选后的对象怪兽全部变成里侧守备表示。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end

--氷風のリフレイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己墓地1只「风魔女」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ●对方连锁自己的「风魔女」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动时才能发动。那个对方的效果无效。
function c19362568.initial_effect(c)
	-- 效果原文内容：①：可以从以下效果选择1个发动。●以自己墓地1只「风魔女」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19362568,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,19362568+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19362568.target)
	e1:SetOperation(c19362568.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：可以从以下效果选择1个发动。●对方连锁自己的「风魔女」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动时才能发动。那个对方的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19362568,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,19362568+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c19362568.discon)
	e2:SetTarget(c19362568.distg)
	e2:SetOperation(c19362568.disop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义了用于筛选墓地中的「风魔女」怪兽的过滤器函数
function c19362568.spfilter(c,e,tp)
	return c:IsSetCard(0xf0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面作用：处理特殊召唤效果的发动时点，检查是否满足发动条件并选择目标
function c19362568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19362568.spfilter(chkc,e,tp) end
	-- 规则层面作用：判断是否满足发动条件，即场上是否有空怪兽区且自己墓地存在符合条件的怪兽
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(c19362568.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：根据过滤器函数从墓地中选择一只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c19362568.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置操作信息，表明该效果将特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：处理特殊召唤效果的发动，将目标怪兽特殊召唤到场上
function c19362568.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以守备表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 规则层面作用：判断是否满足无效效果的发动条件，即对方发动的效果是否可以被无效且该效果是否来自己方的「风魔女」怪兽
function c19362568.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查当前连锁的效果是否可以被无效
	if not Duel.IsChainDisablable(ev) then return false end
	-- 规则层面作用：获取上一个连锁的效果和发动玩家信息
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandler():IsSetCard(0xf0) and te:IsActiveType(TYPE_MONSTER) and p==tp and rp==1-tp
end
-- 规则层面作用：处理无效效果的发动时点，设置操作信息表明该效果将使对方效果无效
function c19362568.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置操作信息，表明该效果将使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 规则层面作用：处理无效效果的发动，使对方效果无效
function c19362568.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：使指定连锁的效果无效
	Duel.NegateEffect(ev)
end

--氷風のリフレイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己墓地1只「风魔女」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ●对方连锁自己的「风魔女」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动时才能发动。那个对方的效果无效。
function c19362568.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●以自己墓地1只「风魔女」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
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
	-- ●对方连锁自己的「风魔女」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动时才能发动。那个对方的效果无效。
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
-- 筛选墓地中属于「风魔女」系列、且满足召唤条件与苏生限制、能够以表侧守备表示被当前效果特殊召唤的怪兽。
function c19362568.spfilter(c,e,tp)
	return c:IsSetCard(0xf0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 作为效果发动时的目标选择函数：在发动时检查可用怪兽区与可选墓地目标；满足则提示玩家从自己墓地选择1只符合条件的「风魔女」怪兽作为对象，并登记特殊召唤的操作信息。
function c19362568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19362568.spfilter(chkc,e,tp) end
	-- 发动合法性判定：若自己场上没有可用的怪兽区域，或墓地中不存在符合条件的「风魔女」怪兽，则不能发动。
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(c19362568.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示选择提示信息，提示内容为『请选择要特殊召唤的卡』，用于接下来选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合筛选条件的「风魔女」怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c19362568.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：确定处理时将把该对象卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的操作：取得对象卡，若对象卡仍在连锁关联中，则将其以表侧守备表示特殊召唤到自己场上。
function c19362568.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的效果对象卡（即先前选择的墓地「风魔女」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上（按常规检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 第二个效果的发动条件：对方连锁自己场上「风魔女」怪兽效果的发动而发动魔法·陷阱·怪兽效果时，且该连锁可以被无效，才能发动。
function c19362568.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认该连锁效果是否能够被无效；若不能被无效，则本效果不能发动。
	if not Duel.IsChainDisablable(ev) then return false end
	-- 获取前一个连锁（即对方发动的那个效果）的效果信息和发动玩家，用于判断其是否为自己「风魔女」怪兽效果的连锁。
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandler():IsSetCard(0xf0) and te:IsActiveType(TYPE_MONSTER) and p==tp and rp==1-tp
end
-- 发动时的目标选择函数：发动时无条件允许，并登记本次无效的对象为对方发动的那个连锁效果。
function c19362568.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的连锁效果（eg为该连锁的效果）登记为无效对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理时，直接无效对方发动的那个连锁效果。
function c19362568.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev（对方发动的效果）无效。
	Duel.NegateEffect(ev)
end

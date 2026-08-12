--異次元の契約書
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己墓地让2张「契约书」卡回到卡组，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
-- ②：自己准备阶段发动。自己受到1000伤害。
-- ③：这张卡被破坏的场合才能发动。自己回复500基本分。被对方的效果破坏的场合，再让自己回复500基本分。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的发动、①效果（除外）、②效果（准备阶段伤害）和③效果（破坏时回复LP）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己墓地让2张「契约书」卡回到卡组，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"伤害效果"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合才能发动。自己回复500基本分。被对方的效果破坏的场合，再让自己回复500基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.rectg)
	e4:SetOperation(s.recop)
	c:RegisterEffect(e4)
end
-- 过滤条件：属于「契约书」系列且能回到卡组的卡。
function s.cfilter(c)
	return c:IsSetCard(0xae) and c:IsAbleToDeckAsCost()
end
-- ①效果的Cost处理函数：从自己墓地选择2张「契约书」卡回到卡组。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2张满足条件的「契约书」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择2张「契约书」卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 显式展示被选中的卡片。
	Duel.HintSelection(g)
	-- 将选中的卡片作为Cost送回卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ①效果的Target处理函数：选择对方场上或墓地的一张卡作为对象，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsAbleToRemove() and chkc:IsControler(1-tp) end
	-- 检查对方场上或墓地是否存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上（其次墓地）选择对方的1张卡作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置连锁的操作信息，表示该效果将除外选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的Operation处理函数：将作为对象的卡除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与连锁相关，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的Condition处理函数：判断当前是否为自己的回合。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的Target处理函数：设置伤害的对象玩家、伤害数值及操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置受到伤害的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置伤害数值为1000。
	Duel.SetTargetParam(1000)
	-- 设置连锁的操作信息，表示将对玩家造成1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- ②效果的Operation处理函数：对自己造成1000点伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的伤害对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依法定效果对目标玩家造成相应数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ③效果的Target处理函数：设置回复LP的对象玩家、回复数值及操作信息。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复LP的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置回复LP的数值为500。
	Duel.SetTargetParam(500)
	-- 设置连锁的操作信息，表示将使玩家回复500点LP。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ③效果的Operation处理函数：自己回复500LP，若被对方效果破坏则再回复500LP。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的回复对象玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复LP的处理，并判断是否成功回复且该卡是被对方的效果所破坏。
	if Duel.Recover(p,d,REASON_EFFECT)>0 and rp==1-tp then
		-- 中断当前效果处理，使后续的回复处理不与前一次回复同时进行。
		Duel.BreakEffect()
		-- 再次使玩家回复500点LP。
		Duel.Recover(p,500,REASON_EFFECT)
	end
end

--重騎甲虫マイティ・ネプチューン
-- 效果：
-- 这张卡不能通常召唤。让除外的3只自己的昆虫族怪兽回到卡组的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：结束阶段，以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
-- ②：自己·对方的主要阶段，场上的这张卡被对方的效果所破坏的场合或者所除外的场合才能发动。这张卡特殊召唤。
function c14357527.initial_effect(c)
	c:EnableReviveLimit()
	-- ②：自己·对方的主要阶段，场上的这张卡被对方的效果所破坏的场合或者所除外的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14357527.sprcon)
	e1:SetTarget(c14357527.sprtg)
	e1:SetOperation(c14357527.sprop)
	c:RegisterEffect(e1)
	-- ①：结束阶段，以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14357527,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,14357527)
	e2:SetCondition(c14357527.spcon)
	e2:SetTarget(c14357527.sptg)
	e2:SetOperation(c14357527.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	-- 这张卡不能通常召唤。让除外的3只自己的昆虫族怪兽回到卡组的场合可以特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14357527,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c14357527.atktg)
	e4:SetOperation(c14357527.atkop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为满足条件的除外怪兽（昆虫族且可送回卡组）
function c14357527.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAbleToDeckAsCost()
end
-- 特殊召唤条件函数，判断是否满足特殊召唤所需条件（有空位且有3只除外昆虫族怪兽）
function c14357527.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否有3只除外的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c14357527.sprfilter,tp,LOCATION_REMOVED,0,3,nil)
end
-- 特殊召唤目标选择函数，用于选择3只除外的昆虫族怪兽
function c14357527.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家除外区域中所有满足条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c14357527.sprfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤执行函数，将选中的怪兽送回卡组并完成特殊召唤
function c14357527.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 为选中的怪兽显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的怪兽送回卡组最底端
	Duel.SendtoDeck(g,nil,2,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 特殊召唤发动条件函数，判断是否在主要阶段且被对方效果破坏或除外
function c14357527.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前是否为主要阶段（1或2）
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤目标选择函数，用于判断是否可以特殊召唤
function c14357527.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤该卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤执行函数，将该卡特殊召唤到场上
function c14357527.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否为满足条件的场上昆虫族怪兽
function c14357527.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 攻击力提升目标选择函数，用于选择场上一只昆虫族怪兽
function c14357527.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c14357527.atkfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否有满足条件的场上昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c14357527.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要提升攻击力的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择场上一只昆虫族怪兽作为目标
	Duel.SelectTarget(tp,c14357527.atkfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 攻击力提升效果执行函数，为选中的怪兽增加1000攻击力
function c14357527.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为选中的怪兽增加1000攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end

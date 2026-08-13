--重騎甲虫マイティ・ネプチューン
-- 效果：
-- 这张卡不能通常召唤。让除外的3只自己的昆虫族怪兽回到卡组的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：结束阶段，以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
-- ②：自己·对方的主要阶段，场上的这张卡被对方的效果所破坏的场合或者所除外的场合才能发动。这张卡特殊召唤。
function c14357527.initial_effect(c)
	c:EnableReviveLimit()
	-- 让除外的3只自己的昆虫族怪兽回到卡组的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14357527.sprcon)
	e1:SetTarget(c14357527.sprtg)
	e1:SetOperation(c14357527.sprop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段，场上的这张卡被对方的效果所破坏的场合或者所除外的场合才能发动。这张卡特殊召唤。
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
	-- ①：结束阶段，以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
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
-- 筛选可作为特殊召唤代价的卡：表侧表示且为昆虫族，并且可以作为代价返回卡组（即除外的自己的昆虫族怪兽）。
function c14357527.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAbleToDeckAsCost()
end
-- 特殊召唤规则的条件：自己主要怪兽区有空位，且除外区存在至少3张满足sprfilter的卡。
function c14357527.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区域是否有可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外的卡中是否存在至少3张满足sprfilter条件的昆虫族怪兽。
		and Duel.IsExistingMatchingCard(c14357527.sprfilter,tp,LOCATION_REMOVED,0,3,nil)
end
-- 特殊召唤手续的目标选择：从符合条件的除外昆虫族中选取3张，保存到效果标签，作为召唤代价；若选择成功则返回true。
function c14357527.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取全部符合条件的除外区昆虫族怪兽，作为可选择的候选组。
	local g=Duel.GetMatchingGroup(c14357527.sprfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要返回卡组的卡（提示文本为“请选择要返回卡组的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：将之前选中的3张除外区昆虫族怪兽展示选中动画，返回持有者卡组，并清除临时保存，完成召唤代价。
function c14357527.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 展示被选中的卡的选择动画，并记录这些卡被选中（广义对象）。
	Duel.HintSelection(g)
	-- 将选中的卡以特殊召唤为原因返回持有者卡组（seq=2表示回到卡组顶并需要洗牌）。
	Duel.SendtoDeck(g,nil,2,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ②效果的发动条件：当前为自己或对方的主要阶段，且这张卡因对方的效果从场上被破坏或除外（此前由自己控制并在场上）。
function c14357527.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前阶段是否为主要阶段1或主要阶段2。
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的发动目标检查：若可发动，确认自己主要怪兽区有空位且此卡可以特殊召唤，并设置操作信息为特殊召唤此卡。
function c14357527.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查：主要怪兽区有空位且这张卡可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息为特殊召唤这张卡（1张，目标为自己，位置由处理时决定），供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若仍有空位且此卡与效果仍关联，则将其表侧攻击表示特殊召唤到自己场上。
function c14357527.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则处理中断，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤给自己（无视召唤条件和苏生限制，因为已用效果特殊召唤）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选①效果可选择的卡：表侧表示且为昆虫族怪兽。
function c14357527.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- ①效果发动时的取对象处理：选择自己场上表侧表示昆虫族怪兽中除这张卡以外的1只作为对象。
function c14357527.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c14357527.atkfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否存在至少1只符合条件的对象：自己场上表侧昆虫族且不是这张卡。
	if chk==0 then return Duel.IsExistingTarget(c14357527.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡（提示文本为“请选择表侧表示的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合条件的表侧昆虫族怪兽（自己场上除自身外），并将其设为效果对象。
	Duel.SelectTarget(tp,c14357527.atkfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ①效果处理：取对象，若对象仍表侧且与效果关联，则使其攻击力上升1000。
function c14357527.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end

--天雷震龍－サンダー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。雷族怪兽的效果在手卡发动的回合，从手卡以及自己场上的表侧表示怪兽之中把1只8星以下的雷族怪兽除外的场合可以特殊召唤。
-- ①：对方回合1次，从自己墓地把包含雷族怪兽的2张卡除外，以自己场上1只雷族怪兽为对象才能发动。这个回合，那只怪兽不会成为对方的效果的对象。
-- ②：自己结束阶段才能发动。从卡组把1张「雷龙」卡送去墓地。
function c5206415.initial_effect(c)
	c:EnableReviveLimit()
	-- 『这张卡不能通常召唤。雷族怪兽的效果在手卡发动的回合，从手卡以及自己场上的表侧表示怪兽之中把1只8星以下的雷族怪兽除外的场合可以特殊召唤。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5206415.spcon)
	e1:SetTarget(c5206415.sptg)
	e1:SetOperation(c5206415.spop)
	c:RegisterEffect(e1)
	-- 『①：对方回合1次，从自己墓地把包含雷族怪兽的2张卡除外，以自己场上1只雷族怪兽为对象才能发动。这个回合，那只怪兽不会成为对方的效果的对象。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5206415,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c5206415.etcon)
	e2:SetCost(c5206415.etcost)
	e2:SetTarget(c5206415.ettg)
	e2:SetOperation(c5206415.etop)
	c:RegisterEffect(e2)
	-- 『②：自己结束阶段才能发动。从卡组把1张「雷龙」卡送去墓地。』
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5206415,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c5206415.tgcon)
	e3:SetTarget(c5206415.tgtg)
	e3:SetOperation(c5206415.tgop)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，监视双方玩家是否发动过雷族怪兽的手卡效果，用于后续特殊召唤条件的判定。
	Duel.AddCustomActivityCounter(5206415,ACTIVITY_CHAIN,c5206415.chainfilter)
end
-- 计数器过滤函数：当某个效果是雷族怪兽在手卡发动时返回 false（表示这类操作会被计数），否则返回 true 不计数，用于记录本回合是否发动过手卡的雷族怪兽效果。
function c5206415.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsRace(RACE_THUNDER) and re:IsActiveType(TYPE_MONSTER)
		-- 追加判断该效果的发动位置是否为手卡，与前面的雷族、怪兽类型条件共同构成『雷族怪兽的效果在手卡发动』的判定。
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND)
end
-- 特殊召唤代价的过滤函数：选择1只8星以下的雷族怪兽，该怪兽可以是手牌或自己场上的表侧表示怪兽，且能够作为代价除外，除外后自己场上仍有可用的怪兽区。
function c5206415.spfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsLevelBelow(8) and c:IsRace(RACE_THUNDER)
		-- 判定该卡可作为代价除外，且除外后自己场上仍有空位可以特殊召唤此卡。
		and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件：当c为nil时返回true（供给系统查询）；否则需要本回合有任意一方玩家在手卡发动过雷族怪兽效果，且场上/手牌存在符合条件的可除外雷族怪兽。
function c5206415.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断发动玩家（自己）本回合是否进行过计数活动，即自己是否发动过手卡雷族怪兽效果。
	return (Duel.GetCustomActivityCount(5206415,tp,ACTIVITY_CHAIN)~=0
		-- 判断对方玩家本回合是否也进行过该计数活动；只要任意一方发动过手卡雷族怪兽效果，就满足特殊召唤所需的前提条件。
		or Duel.GetCustomActivityCount(5206415,1-tp,ACTIVITY_CHAIN)~=0)
		-- 检查自己手牌或场上是否存在1只满足除外代价条件的雷族怪兽（除自身以外），存在则特殊召唤条件成立。
		and Duel.IsExistingMatchingCard(c5206415.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,tp)
end
-- 特殊召唤规则的目标选择函数：从手牌和场上表侧表示的怪兽中选出1只8星以下雷族怪兽作为除外的对象，并将选择结果存入效果标签，供处理时除外。
function c5206415.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足除外代价条件的雷族怪兽候选组，排除自身c。
	local g=Duel.GetMatchingGroup(c5206415.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c,tp)
	-- 向操作玩家发送提示消息，提示其正在选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理：将之前选择的雷族怪兽以表侧表示除外，完成特殊召唤手续。
function c5206415.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以表侧表示除外，原因为特殊召唤（REASON_SPSUMMON），以支付特殊召唤代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动条件：当前回合玩家是对方，即只能在对方回合发动。
function c5206415.etcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为对方回合，是则返回true。
	return Duel.GetTurnPlayer()==1-tp
end
-- 费用子组选择过滤函数：要求选出的卡片组中至少存在1张雷族怪兽，以满足『包含雷族怪兽的2张卡』的代价要求。
function c5206415.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_THUNDER)
end
-- ①效果的代价：从自己墓地选择包含雷族怪兽的2张卡除外，进行选择并执行除外。
function c5206415.etcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有可以作为代价除外的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(c5206415.fselect,2,2) end
	-- 提示玩家正在选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c5206415.fselect,false,2,2)
	-- 将选中的2张卡片以表侧表示除外，作为效果的发动代价（REASON_COST）。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ①效果的目标过滤：必须是表侧表示的雷族怪兽。
function c5206415.etfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- ①效果的取对象处理：选择自己场上1只表侧表示的雷族怪兽作为对象。
function c5206415.ettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5206415.etfilter(chkc) end
	-- 效果发动前检查：确认自己场上存在至少1只满足条件的表侧表示雷族怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c5206415.etfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家正在选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只表侧表示雷族怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c5206415.etfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：使作为对象的自己场上的雷族怪兽在这个回合内不会成为对方发动的效果的对象。
function c5206415.etop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理中第一个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 『这个回合，那只怪兽不会成为对方的效果的对象。』
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetValue(c5206415.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
-- 该效果的Value函数：只有对方发动的效果（rp==1-e:GetOwnerPlayer()）才会使该抗性生效，即只免疫对方的效果。
function c5206415.tgoval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
-- ②效果的发动条件：当前回合为自己，即只能在自己的结束阶段发动。
function c5206415.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是己方，是则返回true，保证在自己结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- ②的过滤条件：卡名属于『雷龙』字段（0x11c）并且可以被送去墓地。
function c5206415.tgfilter(c)
	return c:IsSetCard(0x11c) and c:IsAbleToGrave()
end
-- ②效果的发动目标确定：确认卡组中存在1张可以送去墓地的『雷龙』卡，并设置效果处理信息为从卡组把1张卡送去墓地。
function c5206415.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查：卡组中是否存在至少1张符合条件的『雷龙』卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c5206415.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组送去墓地，用于后续相关效果判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张『雷龙』卡送去墓地。
function c5206415.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家正在选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张符合条件的『雷龙』卡。
	local g=Duel.SelectMatchingCard(tp,c5206415.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地，原因为效果（REASON_EFFECT）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

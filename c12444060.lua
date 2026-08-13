--アーティファクトの神智
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
-- ①：从卡组把1只「古遗物」怪兽特殊召唤。
-- ②：这张卡被对方破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c12444060.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。①：从卡组把1只「古遗物」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12444060,0))  --"破坏"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_END_PHASE)
	e1:SetCountLimit(1,12444060+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c12444060.cost)
	e1:SetTarget(c12444060.target)
	e1:SetOperation(c12444060.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12444060,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c12444060.descon)
	e2:SetTarget(c12444060.destg)
	e2:SetOperation(c12444060.desop)
	c:RegisterEffect(e2)
end
-- 作为发动代价，检测本回合是否还未进入过战斗阶段；在支付代价时，给发动者附加本回合不能进入战斗阶段的誓约效果。
function c12444060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检测：本回合尚未进行过战斗阶段（进入战斗阶段的次数为0）时才满足发动条件。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。①：从卡组把1只「古遗物」怪兽特殊召唤。②：这张卡被对方破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的“不能进入战斗阶段”效果注册给当前玩家tp，使该限制在本回合剩余时间内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤的过滤器：候选卡必须是「古遗物」怪兽，并且能够被当前效果特殊召唤。
function c12444060.filter(c,e,tp)
	return c:IsSetCard(0x97) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件：我方主要怪兽区有空位，且卡组中存在满足条件的「古遗物」怪兽可供特殊召唤。
function c12444060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测我方主要怪兽区是否有至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1只满足 c12444060.filter 条件的「古遗物」怪兽。
		and Duel.IsExistingMatchingCard(c12444060.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示本次效果将进行特殊召唤，预计从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区仍空出位置，则从卡组选择1只符合条件的「古遗物」怪兽表侧表示特殊召唤。
function c12444060.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认主要怪兽区有空格；若已经没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足 c12444060.filter 条件的「古遗物」怪兽。
	local g=Duel.SelectMatchingCard(tp,c12444060.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到操作者场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡是被对方破坏，且被破坏前由自己控制。
function c12444060.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果的发动与目标选择：以场上存在的任意1张卡为对象（取对象），并设置破坏的操作信息。
function c12444060.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动检测：场上是否至少有1张卡能够成为效果的对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，标明本次效果将破坏对象卡，对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象仍与该效果关联，则将其破坏。
function c12444060.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

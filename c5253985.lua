--交差する魂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段才能发动。把1只幻神兽族怪兽上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。把对方场上的怪兽解放作上级召唤的场合，以下效果适用。
-- ●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
function c5253985.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段才能发动。进行1只幻神兽族怪兽的上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。把对方场上的怪兽解放作上级召唤的场合，以下效果适用。●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5253985,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,5253985+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c5253985.sumcon)
	e1:SetTarget(c5253985.sumtg)
	e1:SetOperation(c5253985.sumop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：当前阶段必须为主要阶段1或主要阶段2，才能发动此卡。
function c5253985.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量ph，用于判断当前是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 召唤对象过滤函数：检查手牌怪兽是否为幻神兽族，若是则临时附加‘可将对方怪兽解放’的效果，并判断其能否以至少1只解放进行上级召唤；用于筛选可被本效果召唤的怪兽。
function c5253985.sumfilter(c,ec)
	if not c:IsRace(RACE_DIVINE) then return false end
	-- 那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local res=c:IsSummonable(true,nil,1)
	e1:Reset()
	return res
end
-- 效果发动的合法性检查：确认手牌中存在可被本效果上级召唤的幻神兽族怪兽，若存在则允许发动并设置召唤类操作信息。
function c5253985.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查（chk==0）是否存在至少1张手牌的幻神兽族怪兽满足上级召唤条件（包括可用对方怪兽代替解放），以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c5253985.sumfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler()) end
	-- 设置本次连锁的处理信息为CATEGORY_SUMMON（上级召唤），数量为1；因具体召唤对象在效果处理时选择，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：选择手牌中1只幻神兽族怪兽进行上级召唤，为其临时增加对方怪兽作为解放的权限，并注册召唤成功后的限制效果；若召唤被无效则撤销监测。
function c5253985.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示选择提示，提示内容为‘请选择要召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌中选择1张满足c5253985.sumfilter条件的幻神兽族怪兽作为要上级召唤的卡片，并取出该卡。
	local tc=Duel.SelectMatchingCard(tp,c5253985.sumfilter,tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
	if tc then
		-- 那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
		e1:SetRange(LOCATION_HAND)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 把对方场上的怪兽解放作上级召唤的场合，以下效果适用。●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		e1:SetOperation(c5253985.limitop)
		-- 将e1注册到场上：在本次主要阶段内持续监测怪兽召唤成功事件，以便在召唤成功后判断是否解放了对方怪兽并施加限制。
		Duel.RegisterEffect(e1,tp)
		-- 把对方场上的怪兽解放作上级召唤的场合，以下效果适用。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_NEGATED)
		e2:SetOperation(c5253985.rstop)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1)
		-- 将e2注册到场上：当这次上级召唤被无效时，重置召唤成功监测效果e1，防止后续误触发限制。
		Duel.RegisterEffect(e2,tp)
		-- 执行上级召唤：以至少1只怪兽为解放（可包含对方怪兽），并将选中的幻神兽族怪兽通常召唤到己方场上。
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 过滤函数：判断解放素材c在被解放前的控制者是否为对方（1-tp），用于识别是否解放了对方怪兽。
function c5253985.cfilter(c,tp)
	return c:IsPreviousControler(1-tp)
end
-- 召唤成功后的处理：检查召唤所用素材中是否存在来自对方场上的怪兽；若有，则为当前玩家设置活动计数器并注册‘非幻神兽族效果发动限制’；然后重置自身。
function c5253985.limitop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	local g=tc:GetMaterial()
	if g and g:IsExists(c5253985.cfilter,1,nil,tp) then
		-- 为tp玩家注册自定义活动计数器，类型为发动效果（ACTIVITY_CHAIN）；当tp发动非幻神兽族效果时计数变为1，作为后续限制的触发标志。
		Duel.AddCustomActivityCounter(5253985,ACTIVITY_CHAIN,c5253985.chainfilter)
		-- ●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(1,0)
		e3:SetCondition(c5253985.actcon)
		e3:SetValue(c5253985.aclimit)
		e3:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将e3注册到场上：对tp玩家持续施加‘不能发动幻神兽族以外效果’的限制，持续到下个回合结束。
		Duel.RegisterEffect(e3,tp)
	end
	e:Reset()
end
-- 召唤被无效时的处理：取出e2保存的e1并重置e1，同时重置e2自身，避免在召唤未成功的情况下错误适用限制效果。
function c5253985.rstop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	if e1 then e1:Reset() end
	e:Reset()
end
-- 计数器过滤函数：只有‘幻神兽族怪兽的效果’返回true（不会使计数器增加）；其他效果返回false，一旦发动该类型效果，计数器增加，表示已发动过非幻神兽族效果。
function c5253985.chainfilter(re,tp,cid)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_DIVINE)
end
-- 限制效果的生效条件：当己方已经发动过非幻神兽族效果（自定义计数器不为0）时，限制效果开始禁止继续发动非幻神兽族效果。
function c5253985.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取并判断当前玩家已发动的非幻神兽族效果计数是否不为0；若不为0，说明已经使用了那1次允许的非幻神兽族效果发动机会。
	return Duel.GetCustomActivityCount(5253985,tp,ACTIVITY_CHAIN)~=0
end
-- 限制判定：若试图发动的效果不是幻神兽族怪兽的效果（即非幻神兽族的魔法·陷阱·怪兽效果），则返回true禁止发动；幻神兽族怪兽效果不受限制。
function c5253985.aclimit(e,re,tp)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_DIVINE))
end

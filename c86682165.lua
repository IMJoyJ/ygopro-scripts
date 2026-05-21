--氷水啼エジル・ギュミル
-- 效果：
-- 水属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合可以发动。这个回合中，自己场上的表侧表示怪兽不会被对方的效果破坏，不能用对方的效果除外。连锁对方的效果的发动把这个效果发动，那些同名卡在对方的场上·墓地存在的场合，可以再把那些同名卡全部除外。
-- ②：这张卡在墓地存在，对方的效果让卡被除外的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（诱发即时效果）和②效果（墓地诱发效果）的注册。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：水属性调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1)
	-- ①：自己·对方回合可以发动。这个回合中，自己场上的表侧表示怪兽不会被对方的效果破坏，不能用对方的效果除外。连锁对方的效果的发动把这个效果发动，那些同名卡在对方的场上·墓地存在的场合，可以再把那些同名卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的效果让卡被除外的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备，若连锁对方的效果发动，则将效果分类设为包含“除外”和“涉及墓地动作”。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetCategory(0)
	-- 获取当前的连锁序号。
	local ch=Duel.GetCurrentChain()
	-- 判断当前连锁数是否大于1，且上一个连锁的发动玩家是否为对方。
	if ch>1 and Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_PLAYER)==1-tp then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	end
end
-- ①效果的处理函数，赋予己方怪兽破坏与除外抗性，并可在连锁对方效果时选择除外对方场上·墓地的同名卡。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合中，自己场上的表侧表示怪兽不会被对方的效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置破坏抗性的来源为对方卡片的效果。
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该回合内生效的不会被对方效果破坏的抗性。
	Duel.RegisterEffect(e1,tp)
	-- 不能用对方的效果除外。连锁对方的效果的发动把这个效果发动，那些同名卡在对方的场上·墓地存在的场合，可以再把那些同名卡全部除外。②：这张卡在墓地存在，对方的效果让卡被除外的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.efilter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该回合内生效的不能被对方效果除外的抗性。
	Duel.RegisterEffect(e2,tp)
	-- 获取当前的连锁序号。
	local ch=Duel.GetCurrentChain()
	if ch>1 then
		-- 获取上一个连锁的发动玩家、卡号以及效果指针。
		local p,code,te=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_EFFECT)
		if p==1-tp then
			if te then
				local tc=te:GetHandler()
				if tc and tc:IsRelateToEffect(te) then
					code=tc:GetCode()
				end
			end
			-- 检索对方场上以及对方墓地中，与被连锁卡片同名的所有可除外的卡片。
			local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,code)
			-- 若存在满足条件的同名卡，则询问玩家是否发动追加的除外效果。
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把对方发动的效果的同名卡除外？"
				-- 中断当前效果处理，使后续的除外处理与前面的抗性赋予不视为同时处理。
				Duel.BreakEffect()
				-- 将检索到的同名卡全部表侧表示除外。
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
-- 过滤不能被除外的卡片：自己场上表侧表示的怪兽，且除外原因是由对方的效果造成。
function s.efilter(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and r&REASON_EFFECT>0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 过滤可被除外的同名卡：场上（含表侧表示）或墓地中，卡名与指定卡号相同且可以被除外的卡。
function s.rmfilter(c,code)
	return c:IsFaceupEx() and c:IsCode(code) and c:IsAbleToRemove()
end
-- 过滤导致除外事件的卡：由对方的效果导致卡片被除外。
function s.cfilter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- ②效果的发动条件：对方的效果让卡被除外，且被除外的卡中不包含这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动准备，检查自身是否可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，以及这张卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表明此效果包含将自身特殊召唤的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理函数，若此卡仍存在于墓地，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

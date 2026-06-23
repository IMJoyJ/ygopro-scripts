--百鬼羅刹 神速ブーン
-- 效果：
-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把「百鬼罗刹 神速布恩」特殊召唤。
function c27868563.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把「百鬼罗刹 神速布恩」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27868563,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c27868563.spcon)
	e1:SetTarget(c27868563.sptg)
	e1:SetOperation(c27868563.spop)
	c:RegisterEffect(e1)
end
-- 检查当前阶段是否为主要阶段1或主要阶段2
function c27868563.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 检测是否满足特殊召唤的条件，包括移除1个超量素材、场上存在空位以及此卡可被特殊召唤
function c27868563.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否能移除1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表明此效果将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果处理，移除超量素材并特殊召唤此卡，同时设置后续限制
function c27868563.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 移除超量素材并确认此卡仍在场上
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把「百鬼罗刹 神速布恩」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27868563.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将限制效果注册到场上，使玩家在接下来的两个回合结束前无法特殊召唤此卡
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标为卡号为27868563的卡
function c27868563.splimit(e,c)
	return c:IsCode(27868563)
end

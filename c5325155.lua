--毒の魔妖－束脛
-- 效果：
-- ①：「毒之魔妖-束胫」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，「毒之魔妖-束胫」以外的自己的「魔妖」怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c5325155.initial_effect(c)
	c:SetUniqueOnField(1,0,5325155)
	-- ②：这张卡在墓地存在，「毒之魔妖-束胫」以外的自己的「魔妖」怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5325155,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c5325155.spcon)
	e1:SetCost(c5325155.spcost)
	e1:SetTarget(c5325155.sptg)
	e1:SetOperation(c5325155.spop)
	c:RegisterEffect(e1)
	-- 设置操作类型为特殊召唤、代号为5325155的计数器，用于限制每回合只能发动一次效果。
	Duel.AddCustomActivityCounter(5325155,ACTIVITY_SPSUMMON,c5325155.counterfilter)
end
-- 过滤函数：若卡片不是从额外卡组召唤或属于魔妖卡组，则不计入计数器。
function c5325155.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x121)
end
-- 条件过滤函数：判断被破坏的怪兽是否为魔妖族、非束胫、在怪兽区被破坏、且由战斗或对方效果造成破坏。
function c5325155.cfilter(c,tp,rp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0x121) and not c:IsCode(5325155)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- 触发条件函数：确认是否有满足条件的怪兽被破坏。
function c5325155.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5325155.cfilter,1,nil,tp,rp)
end
-- 发动费用函数：检查本回合是否已发动过特殊召唤，若未发动则设置不能从额外卡组特殊召唤的效果。
function c5325155.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在本回合已经发动过特殊召唤，若为0则表示可以发动。
	if chk==0 then return Duel.GetCustomActivityCount(5325155,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个限制对方不能从额外卡组特殊召唤的永续效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c5325155.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该限制效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 设置特殊召唤目标函数：检查是否有足够的怪兽区域和是否能特殊召唤。
function c5325155.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置连锁操作信息，表示本次处理的是特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将卡片特殊召唤到场上。
function c5325155.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将卡片以正面表示形式召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制效果的目标过滤函数：若卡片在额外卡组且不属于魔妖族，则不能特殊召唤。
function c5325155.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end

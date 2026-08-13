--D-HERO ドローガイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「英雄」怪兽的效果特殊召唤成功的场合才能发动。双方玩家各自从卡组抽1张。
-- ②：这张卡被送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c48150362.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡用「英雄」怪兽的效果特殊召唤成功的场合才能发动。双方玩家各自从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48150362,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,48150362)
	e1:SetCondition(c48150362.drcon)
	e1:SetTarget(c48150362.drtg)
	e1:SetOperation(c48150362.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，下次的准备阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c48150362.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48150362,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,48150363)
	e3:SetCondition(c48150362.spcon)
	e3:SetTarget(c48150362.sptg)
	e3:SetOperation(c48150362.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：本次特殊召唤必须是由持有『英雄』字段的怪兽效果发动的特殊召唤（re存在且是怪兽效果，且处理者卡组的卡名含『英雄』字段）。
function c48150362.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x8)
end
-- ①效果的发动目标处理：在发动前确认双方都能抽卡，并登记抽卡效果信息。
function c48150362.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法性检查：只有我方和对方都能够抽1张卡时才允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 登记操作信息：将本效果标记为抽卡效果，预定让双方玩家各抽1张（PLAYER_ALL表示双方，1张）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- ①效果结算：双方玩家各自从卡组抽1张卡。
function c48150362.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 我方以效果原因抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 对方以效果原因抽1张卡。
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
-- ②效果的前置处理：当这张卡被送去墓地时，注册一个标记以记录这一事实；若是在准备阶段被送去，标记保留到下一个准备阶段（跳过当前阶段），否则在下一个准备阶段即可使用，以此实现『下次的准备阶段才能发动』。
function c48150362.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为准备阶段，决定标记需要保留多久。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 为这张卡注册标记：以当前回合数作为标记值，并设置重置时间为下一个准备阶段；若当前是准备阶段，则重置计数为2，确保不会在同一准备阶段立即满足条件。
		e:GetHandler():RegisterFlagEffect(48150362,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(48150362,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1,0)
	end
end
-- ②效果的发动条件：确认这张卡已在之前送去过墓地，并且当前回合数不等于标记记录的回合数（即当前是下一个准备阶段）。
function c48150362.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(48150362)
	-- 只有当标记存在，且标记中的回合数与当前回合数不同（即确实到了下次准备阶段）时，返回真。
	return tid and tid~=Duel.GetTurnCount()
end
-- ②效果发动时检查：我方的主要怪兽区有空位，且这张卡在墓地可以进行特殊召唤，满足条件才可发动。
function c48150362.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：我方场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本效果为特殊召唤效果，预定特殊召唤的对象是这张卡本身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果结算：如果这张卡仍与效果关联，就将其以表侧表示特殊召唤到我方场上；特殊召唤成功后，给它附加一个离场时除外的不入连锁效果。
function c48150362.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 先确认这张卡没有被效果处理中离开或失效，然后以表侧表示特殊召唤到我方场上；只有特殊召唤成功时才继续附加除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

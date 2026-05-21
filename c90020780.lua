--シノビネクロ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，从自己墓地有这张卡以外的不死族怪兽特殊召唤的场合才能发动。自己从卡组抽1张。那之后，选1张手卡丢弃。
-- ②：墓地的这张卡为让效果发动而被除外的场合或者被效果除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c90020780.initial_effect(c)
	-- ①：这张卡已在怪兽区域存在的状态，从自己墓地有这张卡以外的不死族怪兽特殊召唤的场合才能发动。自己从卡组抽1张。那之后，选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,90020780)
	e1:SetCondition(c90020780.drcon)
	e1:SetTarget(c90020780.drtg)
	e1:SetOperation(c90020780.drop)
	c:RegisterEffect(e1)
	-- ②：墓地的这张卡为让效果发动而被除外的场合或者被效果除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,90020781)
	e2:SetCondition(c90020780.spcon)
	e2:SetTarget(c90020780.sptg)
	e2:SetOperation(c90020780.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：从自己墓地特殊召唤的不死族怪兽
function c90020780.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsRace(RACE_ZOMBIE)
end
-- 发动条件：这张卡在场上存在，且有这张卡以外的不死族怪兽从自己墓地特殊召唤
function c90020780.drcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	return eg:IsExists(c90020780.cfilter,1,e:GetHandler(),tp)
end
-- 效果①的发动准备（检查是否能抽卡，并设置抽卡和丢弃手卡的操作信息）
function c90020780.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息：由自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息：由自己丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的效果处理（抽1张卡，然后选1张手卡丢弃）
function c90020780.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 如果成功因效果抽卡
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 洗切手卡
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续的丢弃手卡不与抽卡同时处理
		Duel.BreakEffect()
		-- 让玩家选择并因效果丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 发动条件：墓地的这张卡因效果或者为让效果发动而被除外
function c90020780.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_GRAVE) and (c:IsReason(REASON_EFFECT)
		or c:IsReason(REASON_COST) and re:IsHasType(0x7f0))
end
-- 效果②的发动准备（检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息）
function c90020780.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（特殊召唤自身，并添加离场时除外的限制）
function c90020780.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡仍与效果相关，且成功以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

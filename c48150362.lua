--D-HERO ドローガイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「英雄」怪兽的效果特殊召唤成功的场合才能发动。双方玩家各自从卡组抽1张。
-- ②：这张卡被送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c48150362.initial_effect(c)
	-- ①：这张卡用「英雄」怪兽的效果特殊召唤成功的场合才能发动。双方玩家各自从卡组抽1张。
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
	-- ②：这张卡被送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c48150362.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
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
-- 判断是否由「英雄」怪兽的效果特殊召唤成功
function c48150362.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x8)
end
-- 设置抽卡效果的处理信息
function c48150362.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置抽卡效果的目标为双方各抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 执行双方各抽一张卡的效果
function c48150362.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家抽一张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家抽一张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
-- 记录墓地效果的触发条件
function c48150362.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 注册标记，用于记录下次准备阶段的回合数
		e:GetHandler():RegisterFlagEffect(48150362,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(48150362,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1,0)
	end
end
-- 判断是否满足特殊召唤条件
function c48150362.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(48150362)
	-- 检查标记的回合数与当前回合数是否不同
	return tid and tid~=Duel.GetTurnCount()
end
-- 设置特殊召唤效果的目标信息
function c48150362.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行将卡片从墓地特殊召唤的效果
function c48150362.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否可以被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将特殊召唤的卡片离场时重定向到除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

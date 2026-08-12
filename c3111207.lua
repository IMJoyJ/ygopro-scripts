--彩宝龍
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡从卡组加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡因效果从自己墓地加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c3111207.initial_effect(c)
	-- ①：这张卡从卡组加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3111207,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,3111207)
	e1:SetCondition(c3111207.spcon1)
	e1:SetTarget(c3111207.sptg1)
	e1:SetOperation(c3111207.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡因效果从自己墓地加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3111207,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,3111207)
	e2:SetCondition(c3111207.spcon2)
	e2:SetTarget(c3111207.sptg2)
	e2:SetOperation(c3111207.spop2)
	c:RegisterEffect(e2)
end
-- 效果条件：这张卡是从卡组加入手牌且控制权未变更且未公开
function c3111207.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp) and not c:IsPublic()
end
-- 效果目标：检查是否满足特殊召唤条件
function c3111207.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤条件：场上是否有空位且该卡能被特殊召唤
	if chk==0 then return c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将该卡加入特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将该卡特殊召唤到场上
function c3111207.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作：将该卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件：这张卡是因效果从墓地加入手牌且控制权未变更且未公开
function c3111207.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(tp) and not c:IsPublic()
end
-- 效果目标：检查是否满足特殊召唤条件
function c3111207.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤条件：场上是否有空位且该卡能被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将该卡加入特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将该卡特殊召唤到场上，并在离场时除外
function c3111207.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行特殊召唤操作并判断是否成功：若成功则注册离场除外效果
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 离场时除外效果：该卡从场上离开时被送入除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

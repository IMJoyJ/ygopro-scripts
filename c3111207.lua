--彩宝龍
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡从卡组加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡因效果从自己墓地加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c3111207.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡从卡组加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡因效果从自己墓地加入手卡的场合，把这张卡给对方观看才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- ①效果的发动条件：这张卡是从卡组加入手卡、且加入手卡前控制者为发动者，并且加入手卡后未处于公开状态（此时需要给对方观看）才能发动。
function c3111207.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp) and not c:IsPublic()
end
-- ①效果发动时的合法检查：此卡仍与效果关联、自己场上有可用的主要怪兽区空格，且此卡可以特殊召唤（不检查苏生限制和召唤条件）。
function c3111207.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动合法性检查时，要求此卡仍与当前效果关联，且自己场上有可用的主要怪兽区空格。
	if chk==0 then return c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设置为特殊召唤，对象为此卡，数量为1（用于特殊召唤相关效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则将其表侧攻击表示特殊召唤到控制者的怪兽区。
function c3111207.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 由当前效果的控制者将此卡以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：此卡是因效果从自己墓地加入手卡、加入前控制者为发动者，且加入后未处于公开状态（需要给对方观看）才能发动。
function c3111207.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(tp) and not c:IsPublic()
end
-- ②效果发动时的合法检查：自己场上有可用的主要怪兽区空格，且此卡可以特殊召唤（不检查苏生限制和召唤条件）。
function c3111207.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动合法性检查时，要求自己场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设置为特殊召唤，对象为此卡，数量为1（用于特殊召唤相关效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若此卡仍与效果关联且特殊召唤成功，则给它附加一个“从场上离开时改为除外”的效果。
function c3111207.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理②效果时，先确认此卡仍与效果关联，然后尝试将其表侧表示特殊召唤；只有召唤成功时才继续附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
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

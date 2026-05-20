--虫忍 ハガクレミノ
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡所连接区有怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
-- ②：这张卡所连接区的怪兽被战斗·效果破坏的场合才能发动。从自己的手卡·墓地把1只4星以下的昆虫族怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c70709488.initial_effect(c)
	-- 设置连接召唤的手续，需要2只怪兽作为素材，且素材需满足lcheck过滤条件（卡名不同）。
	aux.AddLinkProcedure(c,nil,2,2,c70709488.lcheck)
	c:EnableReviveLimit()
	-- ①：只要这张卡所连接区有怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c70709488.tgcon)
	-- 设置不能成为攻击对象效果的过滤函数（自身不会因不受效果影响而免疫此限制）。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽被战斗·效果破坏的场合才能发动。从自己的手卡·墓地把1只4星以下的昆虫族怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,70709488)
	e2:SetCondition(c70709488.spcon)
	e2:SetTarget(c70709488.sptg)
	e2:SetOperation(c70709488.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：检查用于连接召唤的怪兽卡名是否各不相同。
function c70709488.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 过滤条件：场上的怪兽卡。
function c70709488.tgfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- 攻击限制效果的启用条件：自身所连接区存在怪兽。
function c70709488.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(c70709488.tgfilter,1,nil)
end
-- 过滤条件：被战斗或效果破坏，且原本存在于本方或对方的指定连接区内的怪兽。
function c70709488.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 特殊召唤效果的发动条件：检查被破坏的怪兽中是否存在于这张卡所连接区的怪兽。
function c70709488.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c70709488.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 过滤条件：手卡或墓地中可以特殊召唤的4星以下的昆虫族怪兽。
function c70709488.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（检查可行性并设置操作信息）。
function c70709488.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本方场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查本方手卡或墓地是否存在至少1只满足条件的昆虫族怪兽。
		and Duel.IsExistingMatchingCard(c70709488.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡或墓地特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的执行逻辑。
function c70709488.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若本方场上已无可用怪兽区域，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或墓地选择1只满足条件的昆虫族怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c70709488.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 尝试将选中的怪兽以表侧表示特殊召唤（分步处理）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end

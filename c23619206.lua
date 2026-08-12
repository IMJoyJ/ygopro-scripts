--死神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把「死神鸟 斯摩夫」以外的1张「斯摩夫」卡送去墓地。
-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
function c23619206.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「死神鸟 斯摩夫」以外的1张「斯摩夫」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23619206,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,23619206)
	e1:SetTarget(c23619206.tgtg)
	e1:SetOperation(c23619206.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23619206,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23619207)
	e2:SetCondition(c23619206.spcon)
	e2:SetTarget(c23619206.sptg)
	e2:SetOperation(c23619206.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选卡组中满足条件的「斯摩夫」卡（不包括自身）
function c23619206.tgfilter(c)
	return c:IsSetCard(0x12d) and not c:IsCode(23619206) and c:IsAbleToGrave()
end
-- 效果处理时检查是否满足条件（卡组中存在符合条件的卡）
function c23619206.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23619206.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡送去墓地
function c23619206.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c23619206.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断对方魔法与陷阱区域是否有卡
function c23619206.cfilter(c)
	return c:GetSequence()<5
end
-- 判断对方魔法与陷阱区域是否没有卡
function c23619206.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方魔法与陷阱区域是否没有卡
	return not Duel.IsExistingMatchingCard(c23619206.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
-- 效果处理时检查是否满足条件（场上存在空位且自身可特殊召唤）
function c23619206.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理信息，表示将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，特殊召唤自身并设置其离场时的处理和回合结束时的限制
function c23619206.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 特殊召唤成功后，设置该卡离场时被除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 设置回合结束时自己不能特殊召唤鸟兽族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23619206.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使对方不能特殊召唤鸟兽族怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数，禁止特殊召唤非鸟兽族怪兽
function c23619206.splimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end

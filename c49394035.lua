--ヴェンデット・コア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只不死族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
-- ●这张卡不会成为对方的效果的对象。
function c49394035.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只不死族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49394035,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,49394035)
	e1:SetCost(c49394035.spcost)
	e1:SetTarget(c49394035.sptg)
	e1:SetOperation(c49394035.spop)
	c:RegisterEffect(e1)
	-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●这张卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,49394036)
	e2:SetCondition(c49394035.mtcon)
	e2:SetOperation(c49394035.mtop)
	c:RegisterEffect(e2)
end
-- 定义①的代价过滤条件：选择自己墓地里这张卡以外的不死族怪兽，且该怪兽可以作为代价除外。
function c49394035.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 处理①的发动代价：从自己墓地把这张卡以外的1只不死族怪兽表侧表示除外（REASON_COST），否则不能发动。
function c49394035.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动①前确认：自己墓地存在至少1张满足条件（这张卡以外的不死族、可作为代价除外）的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c49394035.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 弹出选卡提示，提示玩家选择要除外的卡（提示文字“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足过滤条件（不死族且可作为代价除外）的卡，不能选择自身，作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c49394035.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择到的怪兽以表侧表示除外，作为发动①的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①的发动时点判定与操作信息设置：确认场上存在主要怪兽区空位、自身可被特殊召唤，若满足则登记特殊召唤操作。
function c49394035.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动①时确认自己的主要怪兽区存在空位，即场上可以腾出位置特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的处理信息：将这张卡以特殊召唤（1张）作为处理结果，供后续检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：将这张卡特殊召唤；若召唤成功，给它附加“从场上离开的场合除外”的离场替代效果。
function c49394035.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前效果关联且特殊召唤成功，以此决定是否继续附加离场除外的效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●这张卡不会成为对方的效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②的触发条件：这张卡作为仪式召唤的素材被使用，且素材来源包括场上的这张卡，并且仪式召唤出的怪兽是「复仇死者」系列。
function c49394035.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- ②的效果处理：给仪式召唤成功的「复仇死者」怪兽赋予“不会成为对方的效果的对象”的永续效果；若该怪兽不是效果怪兽，则将其变成效果怪兽，并显示效果适用提示。
function c49394035.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- ●这张卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置抗性效果的判定函数：只对对方发动的效果生效（即不会成为对方的效果的对象）。
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●这张卡不会成为对方的效果的对象。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(49394035,1))  --"「复仇死者之核」效果适用中"
end

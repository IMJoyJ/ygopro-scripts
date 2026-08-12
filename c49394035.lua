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
-- 过滤函数，用于筛选满足条件的不死族怪兽（可作为除外的代价）
function c49394035.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 起动效果的费用处理，检查是否满足除外1只不死族怪兽的条件并选择执行除外操作
function c49394035.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的不死族怪兽可用于除外作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(c49394035.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只不死族怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c49394035.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡从游戏中除外（作为费用）
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤的发动条件判断，检查是否有足够的怪兽区域和是否可以特殊召唤
function c49394035.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示即将进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的处理函数，将卡片特殊召唤到场上并注册离场时除外的效果
function c49394035.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断特殊召唤是否成功，并注册离场时除外的效果
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个效果，使该卡在离开场上时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 条件函数，判断是否为仪式召唤的素材且为复仇死者族
function c49394035.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- 当卡片作为仪式召唤的素材时触发的效果处理，给对应的「复仇死者」怪兽添加不会成为对方效果对象的效果
function c49394035.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- 给「复仇死者」怪兽添加不会成为对方效果对象的效果
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果为不会成为对方效果的对象（使用辅助函数）
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若「复仇死者」怪兽没有效果类型，则为其添加TYPE_EFFECT类型
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(49394035,1))  --"「复仇死者之核」效果适用中"
end

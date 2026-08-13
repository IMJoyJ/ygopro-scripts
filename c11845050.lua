--ライトハンド・シャーク
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把1只「左手鲨」加入手卡。
-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡不会被战斗破坏。
function c11845050.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只「左手鲨」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11845050,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,11845050)
	e1:SetTarget(c11845050.thtg)
	e1:SetOperation(c11845050.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11845050,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11845051)
	e2:SetCondition(c11845050.spcon)
	e2:SetTarget(c11845050.sptg)
	e2:SetOperation(c11845050.spop)
	c:RegisterEffect(e2)
	-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。●这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,11845052)
	e3:SetCondition(c11845050.effcon)
	e3:SetOperation(c11845050.effop)
	c:RegisterEffect(e3)
end
-- thfilter：检索条件，必须为卡号47840168（「左手鲨」）且能被加入手卡。
function c11845050.thfilter(c)
	return c:IsCode(47840168) and c:IsAbleToHand()
end
-- thtg：效果发动时的目标判定函数，检查卡组中是否存在符合条件的「左手鲨」，并设置将1张卡从卡组加入手卡的操作信息。
function c11845050.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查卡组中是否存在至少1张满足thfilter条件的「左手鲨」，作为发动合法性的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c11845050.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁处理的操作信息：从卡组将1张卡加入手卡（CATEGORY_TOHAND），用于后续的连锁响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- thop：效果处理时，让玩家从卡组选择1只「左手鲨」加入手卡，并让对方确认。
function c11845050.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示，将选择消息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter的「左手鲨」（执行实际选择）。
	local g=Duel.SelectMatchingCard(tp,c11845050.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- spcon：②效果的发动条件，要求自己场上没有怪兽存在。
function c11845050.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）怪兽数量为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- sptg：②效果的发动目标判定，确认自己场上有可用怪兽区且此卡可以特殊召唤，并设置特殊召唤的操作信息。
function c11845050.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查自己场上有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的处理信息：将这张卡特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- spop：效果处理时，将此卡从墓地特殊召唤；若成功，则给它赋予“离场时除外”的持续效果。
function c11845050.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联后，以表侧表示特殊召唤；若特殊召唤成功（返回值≠0），继续赋予除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。●这张卡不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- cfilter：过滤素材中是否存在不是水属性的怪兽，用于判定是否“只用包含场上的这张卡的水属性怪兽为素材”。
function c11845050.cfilter(c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- effcon：③效果的触发条件，确认这张卡在场上作为超量素材、所有素材均为水属性（且都是怪兽卡）。
function c11845050.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetReasonCard():GetMaterial()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD) and not mg:IsExists(c11845050.cfilter,1,nil)
		and mg:FilterCount(Card.IsXyzType,nil,TYPE_MONSTER)==mg:GetCount()
end
-- effop：给超量召唤出的怪兽赋予“不会被战斗破坏”的效果；若该怪兽不是效果怪兽，则追加将其变为效果怪兽，以便正确获得效果文本。
function c11845050.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(11845050,2))  --"「右手鲨」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。（若怪兽不是效果怪兽，则将其变为效果怪兽以承载效果）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end

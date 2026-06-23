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
-- 检索满足条件的「左手鲨」卡片
function c11845050.thfilter(c)
	return c:IsCode(47840168) and c:IsAbleToHand()
end
-- 效果处理时的判断函数
function c11845050.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c11845050.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数
function c11845050.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的「左手鲨」卡片
	local g=Duel.SelectMatchingCard(tp,c11845050.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤条件判断函数
function c11845050.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 特殊召唤效果处理时的判断函数
function c11845050.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理函数
function c11845050.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤后离场时的去向为除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤非水属性怪兽的函数
function c11845050.cfilter(c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 超量召唤效果适用条件判断函数
function c11845050.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetReasonCard():GetMaterial()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD) and not mg:IsExists(c11845050.cfilter,1,nil)
		and mg:FilterCount(Card.IsXyzType,nil,TYPE_MONSTER)==mg:GetCount()
end
-- 超量召唤效果处理函数
function c11845050.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 给超量召唤的怪兽添加不会被战斗破坏的效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(11845050,2))  --"「右手鲨」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 给超量召唤的怪兽添加效果怪兽类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end

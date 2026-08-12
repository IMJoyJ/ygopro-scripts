--クロノダイバー・アジャスター
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己对「时间潜行者·腕表调校员」以外的「时间潜行者」怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「时间潜行者·腕表调校员」以外的1张「时间潜行者」卡送去墓地。
function c64730881.initial_effect(c)
	-- ①：自己对「时间潜行者·腕表调校员」以外的「时间潜行者」怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64730881,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,64730881)
	e1:SetCondition(c64730881.spcon)
	e1:SetTarget(c64730881.sptg)
	e1:SetOperation(c64730881.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「时间潜行者·腕表调校员」以外的1张「时间潜行者」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64730881,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,64730881)
	e3:SetTarget(c64730881.tgtg)
	e3:SetOperation(c64730881.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己召唤·特殊召唤成功的「时间潜行者·腕表调校员」以外的「时间潜行者」怪兽
function c64730881.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x126) and not c:IsCode(64730881) and c:IsSummonPlayer(tp)
end
-- 发动条件：检查召唤·特殊召唤成功的怪兽中是否存在满足过滤条件的怪兽
function c64730881.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64730881.cfilter,1,nil,tp)
end
-- 效果发动准备（Target）：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c64730881.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理（Operation）：将手卡的这张卡特殊召唤
function c64730881.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中「时间潜行者·腕表调校员」以外的「时间潜行者」卡
function c64730881.tgfilter(c)
	return c:IsSetCard(0x126) and not c:IsCode(64730881) and c:IsAbleToGrave()
end
-- 效果发动准备（Target）：检查卡组中是否存在满足条件的卡，并设置送去墓地的操作信息
function c64730881.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64730881.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）：从卡组选择1张满足条件的卡送去墓地
function c64730881.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c64730881.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

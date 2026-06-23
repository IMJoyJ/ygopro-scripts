--バラガール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的表侧表示的植物族怪兽被送去墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在，场上有植物族怪兽存在的场合才能发动。这张卡加入手卡。
function c29177818.initial_effect(c)
	-- 创建一个触发效果，用于处理自己场上的植物族怪兽被送去墓地时的特殊召唤效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29177818,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,29177818)
	e1:SetCondition(c29177818.spcon)
	e1:SetTarget(c29177818.sptg)
	e1:SetOperation(c29177818.spop)
	c:RegisterEffect(e1)
	-- 创建一个起动效果，用于在墓地时将自己加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29177818,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29177818)
	e2:SetCondition(c29177818.thcon)
	e2:SetTarget(c29177818.thtg)
	e2:SetOperation(c29177818.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被送去墓地的怪兽是否为场上表侧表示的植物族怪兽
function c29177818.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)>0 and c:IsRace(RACE_PLANT)
end
-- 条件函数，判断是否有满足条件的植物族怪兽被送去墓地
function c29177818.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29177818.cfilter,1,nil,tp)
end
-- 目标函数，判断是否可以将此卡特殊召唤
function c29177818.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c29177818.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断场上是否存在表侧表示的植物族怪兽
function c29177818.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 条件函数，判断场上有无植物族怪兽存在
function c29177818.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在至少1只表侧表示的植物族怪兽
	return Duel.IsExistingMatchingCard(c29177818.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 目标函数，判断是否可以将此卡加入手卡
function c29177818.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，表示将此卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将此卡加入手卡的操作
function c29177818.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将此卡送入手卡的操作
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对手查看此卡
		Duel.ConfirmCards(1-tp,c)
	end
end

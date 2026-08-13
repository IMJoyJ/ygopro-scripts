--バラガール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的表侧表示的植物族怪兽被送去墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在，场上有植物族怪兽存在的场合才能发动。这张卡加入手卡。
function c29177818.initial_effect(c)
	-- ①：自己场上的表侧表示的植物族怪兽被送去墓地的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡在墓地存在，场上有植物族怪兽存在的场合才能发动。这张卡加入手卡。
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
-- 筛选被送去墓地的卡是否满足：来自主要怪兽区、控制者为己方、表侧表示、且在场上的种族为植物族的过滤函数。
function c29177818.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)>0 and c:IsRace(RACE_PLANT)
end
-- 触发条件：事件组eg中存在至少1张满足cfilter条件的卡，即自己场上有表侧表示的植物族怪兽被送去墓地。
function c29177818.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29177818.cfilter,1,nil,tp)
end
-- ①效果发动时点判定（chk==0）：确认自己场上有怪兽区空格，且手卡中的此卡可以被特殊召唤。
function c29177818.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将特殊召唤的对象为效果持有者（这张卡），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：取出效果持有者，若其仍与这个效果关联，则执行特殊召唤。
function c29177818.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到持有者tp的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：筛选场上表侧表示且种族为植物族的怪兽。
function c29177818.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- ②效果的发动条件：确认场上（双方）存在至少1只表侧表示的植物族怪兽。
function c29177818.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的植物族怪兽，存在1只以上即可发动②效果。
	return Duel.IsExistingMatchingCard(c29177818.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ②效果发动时点判定（chk==0）：确认墓地中的此卡可以被加入手卡，并设置操作信息。
function c29177818.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 登记操作信息：本次效果将把此卡加入手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若墓地中的此卡仍与效果关联，则将其加入手卡，并向对方展示。
function c29177818.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将墓地中的此卡送去持有者的手卡（加入手卡）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示这张卡，确认其已加入手卡。
		Duel.ConfirmCards(1-tp,c)
	end
end

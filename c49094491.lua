--転生炎獣フェネック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的自己场上的电子界族怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡作为连接2以上的电子界族连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「转生炎兽」通常魔法卡加入手卡。
function c49094491.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的自己场上的电子界族怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49094491,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,49094491)
	e1:SetCondition(c49094491.spcon)
	e1:SetTarget(c49094491.sptg)
	e1:SetOperation(c49094491.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接2以上的电子界族连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「转生炎兽」通常魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49094491,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,49094492)
	e2:SetCondition(c49094491.thcon)
	e2:SetTarget(c49094491.thtg)
	e2:SetOperation(c49094491.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被破坏的怪兽是否满足条件：由自己控制、在场上正面表示、种族为电子界、是从额外卡组召唤、且是因战斗或对方效果而破坏。
function c49094491.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and bit.band(c:GetPreviousRaceOnField(),RACE_CYBERSE)~=0 and c:IsSummonLocation(LOCATION_EXTRA)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 触发条件函数，检查是否有满足cfilter条件的怪兽被破坏。
function c49094491.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49094491.cfilter,1,e:GetHandler(),tp)
end
-- 特殊召唤的发动时点处理函数，判断是否可以进行特殊召唤。
function c49094491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将此卡特殊召唤到场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，执行特殊召唤并设置效果使其不能被送入墓地。
function c49094491.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能参与特殊召唤，并执行特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个永续效果，使该卡从场上离开时被移除（不进入墓地）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 检索效果的触发条件函数，判断此卡是否因作为连接素材而进入墓地且其来源为电子界族连接怪兽且连接值≥2。
function c49094491.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and rc:IsRace(RACE_CYBERSE) and rc:IsLinkAbove(2)
end
-- 过滤函数，用于筛选卡组中满足条件的「转生炎兽」通常魔法卡。
function c49094491.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x119) and c:IsAbleToHand()
end
-- 检索效果的发动时点处理函数，判断是否可以进行检索。
function c49094491.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在至少一张符合条件的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49094491.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将一张魔法卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并把符合条件的魔法卡加入手牌。
function c49094491.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c49094491.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡送入手牌。
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		-- 向对方确认所选的魔法卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

--転生炎獣フェネック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的自己场上的电子界族怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡作为连接2以上的电子界族连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「转生炎兽」通常魔法卡加入手卡。
function c49094491.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的自己场上的电子界族怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 判定被破坏的怪兽是否满足：为我方场上表侧表示的电子界族、从额外卡组特殊召唤，且被战斗或对方的效果破坏。
function c49094491.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and bit.band(c:GetPreviousRaceOnField(),RACE_CYBERSE)~=0 and c:IsSummonLocation(LOCATION_EXTRA)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 检查本次破坏的怪兽中是否存在满足①条件的电子界族怪兽。
function c49094491.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49094491.cfilter,1,e:GetHandler(),tp)
end
-- 效果发动时确认：自己场上是否有空位且这张卡可以被特殊召唤。
function c49094491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将效果处理信息标记为特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡特殊召唤，若成功则为其附加“从场上离开的场合除外”的效果。
function c49094491.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡没有因发动而失去联系，则将其表侧表示特殊召唤；若召唤成功则继续执行离场除外处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡作为连接2以上的电子界族连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「转生炎兽」通常魔法卡加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②的发动条件：这张卡在墓地，且是作为连接2以上的电子界族连接怪兽的连接素材被送去墓地。
function c49094491.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and rc:IsRace(RACE_CYBERSE) and rc:IsLinkAbove(2)
end
-- 检索的卡片条件：通常魔法卡、卡名带有「转生炎兽」、且可以加入手卡。
function c49094491.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x119) and c:IsAbleToHand()
end
-- ②的发动条件：卡组存在符合条件的「转生炎兽」通常魔法卡；并设置检索回手牌的效果信息。
function c49094491.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中是否存在符合条件的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c49094491.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将效果处理信息标记为从卡组检索1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1张符合条件的「转生炎兽」通常魔法卡加入手牌，并让对方确认。
function c49094491.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组筛选1张符合条件的「转生炎兽」通常魔法卡。
	local g=Duel.SelectMatchingCard(tp,c49094491.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌，原因记为效果。
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		-- 向对方展示加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

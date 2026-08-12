--スカー・ヴェンデット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把1张「复仇死者」魔法·陷阱卡加入手卡。
-- ②：这张卡在墓地存在的状态，场上的怪兽被解放的场合，从自己墓地把这张卡以外的1只不死族怪兽除外才能发动。这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「复仇死者」怪兽不能特殊召唤。
function c1855886.initial_effect(c)
	-- ①：这张卡被送去墓地的场合才能发动。从卡组把1张「复仇死者」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1855886)
	e1:SetTarget(c1855886.thtg)
	e1:SetOperation(c1855886.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，场上的怪兽被解放的场合，从自己墓地把这张卡以外的1只不死族怪兽除外才能发动。这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「复仇死者」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,1855887)
	e2:SetCondition(c1855886.spcon)
	e2:SetCost(c1855886.spcost)
	e2:SetTarget(c1855886.sptg)
	e2:SetOperation(c1855886.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「复仇死者」魔法·陷阱卡
function c1855886.thfilter(c)
	return c:IsSetCard(0x106) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「复仇死者」魔法·陷阱卡
function c1855886.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「复仇死者」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1855886.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「复仇死者」魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动和执行，选择并检索「复仇死者」魔法·陷阱卡
function c1855886.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「复仇死者」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c1855886.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足特殊召唤条件
function c1855886.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_MZONE) and not eg:IsContains(e:GetHandler())
end
-- 过滤满足条件的不死族怪兽
function c1855886.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 处理效果的发动和执行，选择并除外不死族怪兽
function c1855886.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在满足条件的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1855886.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c1855886.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的不死族怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤的条件
function c1855886.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在特殊召唤的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的发动和执行，特殊召唤此卡并设置限制
function c1855886.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在特殊召唤的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置特殊召唤后限制非「复仇死者」怪兽特殊召唤的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c1855886.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制非「复仇死者」怪兽特殊召唤
function c1855886.splimit(e,c)
	return not c:IsSetCard(0x106)
end

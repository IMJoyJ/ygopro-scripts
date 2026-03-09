--天空神騎士ロードパーシアス
-- 效果：
-- 天使族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。把1张「天空的圣域」或者有那个卡名记述的卡从卡组加入手卡。场上有「天空的圣域」存在的场合，可以把加入手卡的卡改成1只天使族怪兽。
-- ②：自己场上的表侧表示的天使族怪兽被送去墓地的场合，从自己墓地把1只天使族怪兽除外才能发动。比除外的怪兽等级高的1只天使族怪兽从手卡特殊召唤。
function c48589580.initial_effect(c)
	-- 记录此卡具有「天空的圣域」的卡名记述
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- 设置此卡为至少需要2只天使族怪兽进行连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2)
	-- ①：丢弃1张手卡才能发动。把1张「天空的圣域」或者有那个卡名记述的卡从卡组加入手卡。场上有「天空的圣域」存在的场合，可以把加入手卡的卡改成1只天使族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48589580,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48589580)
	e1:SetCost(c48589580.thcost)
	e1:SetTarget(c48589580.thtg)
	e1:SetOperation(c48589580.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的天使族怪兽被送去墓地的场合，从自己墓地把1只天使族怪兽除外才能发动。比除外的怪兽等级高的1只天使族怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48589580,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,48589581)
	e2:SetCondition(c48589580.spcon)
	e2:SetCost(c48589580.spcost)
	e2:SetTarget(c48589580.sptg)
	e2:SetOperation(c48589580.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用处理：丢弃1张手牌
function c48589580.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器函数：判断是否为「天空的圣域」或满足条件的天使族怪兽
function c48589580.thfilter(c,thchk)
	-- 返回值为true表示该卡是「天空的圣域」或满足条件的天使族怪兽且能加入手牌
	return (aux.IsCodeOrListed(c,56433456) or thchk and c:IsRace(RACE_FAIRY)) and c:IsAbleToHand()
end
-- 效果发动时的处理：选择从卡组检索的卡片
function c48589580.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上有无「天空的圣域」场地卡
	local thchk=Duel.IsEnvironment(56433456)
	-- 检查是否有满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48589580.thfilter,tp,LOCATION_DECK,0,1,nil,thchk) end
	-- 设置连锁操作信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理：执行检索并加入手牌
function c48589580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有无「天空的圣域」场地卡
	local thchk=Duel.IsEnvironment(56433456)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c48589580.thfilter,tp,LOCATION_DECK,0,1,1,nil,thchk)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断怪兽是否为天使族且从场上离开时处于表侧表示状态
function c48589580.cfilter(c,tp)
	return bit.band(c:GetPreviousRaceOnField(),RACE_FAIRY)~=0 and c:IsRace(RACE_FAIRY)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 触发效果的条件：有天使族怪兽被送去墓地
function c48589580.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48589580.cfilter,1,nil,tp)
end
-- 设置特殊召唤效果的费用处理标签
function c48589580.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 除外过滤器函数：判断是否为满足等级要求的天使族怪兽
function c48589580.costfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 返回值为true表示该怪兽是天使族且等级大于0且手牌中有比它等级高的天使族怪兽可特殊召唤
	return lv>0 and c:IsRace(RACE_FAIRY) and Duel.IsExistingMatchingCard(c48589580.spfilter,tp,LOCATION_HAND,0,1,nil,lv+1,e,tp)
end
-- 特殊召唤过滤器函数：判断是否为满足等级要求的天使族怪兽
function c48589580.spfilter(c,lv,e,tp)
	return c:IsLevelAbove(lv) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动时的处理：选择除外的怪兽并设置目标怪兽等级
function c48589580.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否有足够的召唤位置
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查墓地是否有满足条件的怪兽可除外
			and Duel.IsExistingMatchingCard(c48589580.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽进行除外
	local rg=Duel.SelectMatchingCard(tp,c48589580.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的怪兽除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 设置连锁操作信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果发动时的处理：执行特殊召唤
function c48589580.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c48589580.spfilter,tp,LOCATION_HAND,0,1,1,nil,lv+1,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--星杯の神子イヴ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤的场合，可以把自己场上1只「星杯」通常怪兽当作调整使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「星遗物」卡加入手卡。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。从自己的卡组·墓地把「星杯的神子 夏娃」以外的1只「星杯」怪兽特殊召唤。
function c94677445.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：1只满足特定条件的怪兽（调整或星杯通常怪兽）作为调整，以及1只以上调整以外的怪兽
	aux.AddSynchroMixProcedure(c,c94677445.matfilter1,nil,nil,aux.NonTuner(nil),1,99)
	-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「星遗物」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94677445,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,94677445)
	e1:SetCondition(c94677445.thcon)
	e1:SetTarget(c94677445.thtg)
	e1:SetOperation(c94677445.thop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合才能发动。从自己的卡组·墓地把「星杯的神子 夏娃」以外的1只「星杯」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94677445,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,94677446)
	e2:SetCondition(c94677445.spcon)
	e2:SetTarget(c94677445.sptg)
	e2:SetOperation(c94677445.spop)
	c:RegisterEffect(e2)
end
-- 过滤同调素材中的调整：本身是调整，或者是自己场上的「星杯」通常怪兽（当作调整使用）
function c94677445.matfilter1(c,syncard)
	return c:IsTuner(syncard) or (c:IsSynchroType(TYPE_NORMAL) and c:IsSetCard(0xfd))
end
-- 效果①的发动条件：这张卡同调召唤成功
function c94677445.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中可检索的「星遗物」卡
function c94677445.thfilter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组中是否存在可检索的「星遗物」卡，并设置检索的操作信息
function c94677445.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「星遗物」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94677445.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张「星遗物」卡加入手牌并给对方确认
function c94677445.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 过滤并让玩家从卡组选择1张「星遗物」卡
	local g=Duel.SelectMatchingCard(tp,c94677445.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：同调召唤的这张卡从怪兽区域送去墓地
function c94677445.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组或墓地中除「星杯的神子 夏娃」以外、可以特殊召唤的「星杯」怪兽
function c94677445.spfilter(c,e,tp)
	return c:IsSetCard(0xfd) and not c:IsCode(94677445) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域是否有空位，以及卡组或墓地中是否存在可特殊召唤的「星杯」怪兽
function c94677445.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的卡组或墓地中是否存在至少1张满足过滤条件的「星杯」怪兽
		and Duel.IsExistingMatchingCard(c94677445.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理：在怪兽区域有空位的情况下，从卡组或墓地选择1只「星杯」怪兽特殊召唤
function c94677445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从卡组或墓地（受王家长眠之谷影响）选择1张「星杯」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94677445.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

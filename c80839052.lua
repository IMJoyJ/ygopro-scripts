--コアキメイル・サプライヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的岩石族怪兽被送去墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「核成供给者」以外的有「核成兽的钢核」的卡名记述的卡或者「核成兽的钢核」加入手卡。
function c80839052.initial_effect(c)
	-- 注册卡片记述了「核成兽的钢核」（卡号：36623431）的事实
	aux.AddCodeList(c,36623431)
	-- ①：自己场上的表侧表示的岩石族怪兽被送去墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80839052,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,80839052)
	e1:SetCondition(c80839052.spcon)
	e1:SetTarget(c80839052.sptg)
	e1:SetOperation(c80839052.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「核成供给者」以外的有「核成兽的钢核」的卡名记述的卡或者「核成兽的钢核」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80839052,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,80839053)
	e2:SetTarget(c80839052.thtg)
	e2:SetOperation(c80839052.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本在自己场上表侧表示存在的岩石族怪兽
function c80839052.spfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and (c:GetPreviousRaceOnField()&RACE_ROCK)>0 and c:IsRace(RACE_ROCK)
end
-- 效果①的发动条件：检查送去墓地的卡中是否存在满足过滤条件的怪兽
function c80839052.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c80839052.spfilter,1,nil,tp)
end
-- 效果①的发动准备与合法性检查（检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息）
function c80839052.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：若这张卡仍在手卡，则将其特殊召唤
function c80839052.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中「核成供给者」以外的有「核成兽的钢核」卡名记述的卡，或者「核成兽的钢核」本身
function c80839052.thfilter(c)
	-- 检查卡片是否能加入手卡，且不是「核成供给者」，并且自身是「核成兽的钢核」或其卡名记述中包含「核成兽的钢核」
	return c:IsAbleToHand() and not c:IsCode(80839052) and aux.IsCodeOrListed(c,36623431)
end
-- 效果②的发动准备与合法性检查（检查卡组是否存在可检索的卡，并设置检索的操作信息）
function c80839052.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80839052.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息，表示此效果将从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1张满足条件的卡加入手卡并给对方确认
function c80839052.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c80839052.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

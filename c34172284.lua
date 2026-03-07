--溟界王－アロン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
-- ②：对方在抽卡阶段以外把卡加入手卡的场合才能发动。对方手卡随机选1张送去墓地。
-- ③：对方场上的怪兽被效果送去墓地的场合才能发动。从自己的卡组·墓地选「溟界王-阿隆」以外的1只光·暗属性的爬虫类族怪兽加入手卡。
function c34172284.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34172284,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,34172284)
	e1:SetCost(c34172284.spcost)
	e1:SetTarget(c34172284.sptg)
	e1:SetOperation(c34172284.spop)
	c:RegisterEffect(e1)
	-- ②：对方在抽卡阶段以外把卡加入手卡的场合才能发动。对方手卡随机选1张送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34172284,1))  --"对方手卡随机选1张送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34172285)
	e2:SetCondition(c34172284.tgcon)
	e2:SetTarget(c34172284.tgtg)
	e2:SetOperation(c34172284.tgop)
	c:RegisterEffect(e2)
	-- ③：对方场上的怪兽被效果送去墓地的场合才能发动。从自己的卡组·墓地选「溟界王-阿隆」以外的1只光·暗属性的爬虫类族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34172284,2))  --"从自己的卡组·墓地选爬虫类族怪兽加入手卡"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,34172286)
	e3:SetCondition(c34172284.thcon)
	e3:SetTarget(c34172284.thtg)
	e3:SetOperation(c34172284.thop)
	c:RegisterEffect(e3)
end
-- 检查是否有满足条件的怪兽组可以解放，用于特殊召唤效果的费用支付。
function c34172284.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组。
	local g=Duel.GetReleaseGroup(tp)
	-- 检查是否满足解放2只怪兽的条件。
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的2只怪兽进行解放。
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 使用额外的解放次数。
	aux.UseExtraReleaseCount(rg,tp)
	-- 实际执行怪兽的解放操作。
	Duel.Release(rg,REASON_COST)
end
-- 检查是否可以将此卡特殊召唤。
function c34172284.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作。
function c34172284.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为抽卡阶段以外的加入手卡情况。
function c34172284.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段不是抽卡阶段且对方有卡加入手牌。
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 检查对方手牌是否存在。
function c34172284.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手牌组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return #g>0 end
	-- 设置送去墓地的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 执行对方手牌随机选1张送去墓地的操作。
function c34172284.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:RandomSelect(tp,1)
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤条件：对方场上被效果送入墓地的怪兽。
function c34172284.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 判断是否有对方场上被效果送入墓地的怪兽。
function c34172284.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34172284.cfilter,1,nil,tp)
end
-- 过滤条件：非溟界王-阿隆、光·暗属性、爬虫类族且可加入手牌的怪兽。
function c34172284.thfilter(c)
	return not c:IsCode(34172284) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 检查是否有满足条件的怪兽可加入手牌。
function c34172284.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c34172284.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置加入手牌的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行检索并加入手牌的操作。
function c34172284.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽加入手牌。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34172284.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

--溟界王－アロン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
-- ②：对方在抽卡阶段以外把卡加入手卡的场合才能发动。对方手卡随机选1张送去墓地。
-- ③：对方场上的怪兽被效果送去墓地的场合才能发动。从自己的卡组·墓地选「溟界王-阿隆」以外的1只光·暗属性的爬虫类族怪兽加入手卡。
function c34172284.initial_effect(c)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡在墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
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
-- ①效果的代价处理：获取可解放怪兽组，检查存在2只符合条件的怪兽，然后由玩家选择2只作为COST解放，并处理额外解放次数。
function c34172284.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得当前玩家场上可作为解放代价的怪兽集合（不含手卡）。
	local g=Duel.GetReleaseGroup(tp)
	-- 发动合法性检查：确认存在2只可解放且在解放后主怪兽区仍有空位的怪兽。
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家从符合条件的怪兽中选取2只作为解放代价。
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 消耗代替解放效果的使用次数（如暗影敌托邦等）。若存在则使用其次数。
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选中的怪兽作为COST解放。
	Duel.Release(rg,REASON_COST)
end
-- ①效果的目标处理：检查这张卡能否被特殊召唤，并登记特殊召唤的操作信息。
function c34172284.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记将这张卡特殊召唤的操作信息（用于效果发动后的处理及连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与发动时的效果关联，则将其特殊召唤。
function c34172284.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到己方场上（正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动条件：当前不是抽卡阶段，且本次加入手卡的卡中存在控制者为对方的卡。
function c34172284.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前不是抽卡阶段，且被加入手卡的卡中有一张控制者为对方。
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- ②效果的目标处理：获取对方手卡，确认有卡可送墓，并登记随机送墓的操作信息。
function c34172284.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方的手卡组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return #g>0 end
	-- 登记从对方手卡随机选1张送去墓地的操作信息（目标为对方手卡，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果处理：从对方手卡随机选择1张卡送去墓地。
function c34172284.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方当前的手卡组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 提示玩家选择要送去墓地的卡（随机选择的界面提示）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:RandomSelect(tp,1)
		-- 将随机选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- ③效果的过滤器：判定一张卡是否为对方场上的怪兽，并因效果被送去墓地（用于③的触发条件）。
function c34172284.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- ③效果发动条件：本次送去墓地的卡中存在满足cfilter的卡（即对方场上的怪兽被效果送去墓地）。
function c34172284.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34172284.cfilter,1,nil,tp)
end
-- 检索目标过滤：不是「溟界王-阿隆」自身，且为光·暗属性、爬虫类族、可加入手卡的怪兽。
function c34172284.thfilter(c)
	return not c:IsCode(34172284) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- ③效果的目标处理：检查卡组·墓地存在符合条件的怪兽，并登记加入手卡的操作信息。
function c34172284.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己的卡组或墓地存在至少1张符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34172284.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记从卡组·墓地选1张怪兽加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ③效果处理：从卡组·墓地选择1张符合条件的怪兽加入手卡，并让对方确认。
function c34172284.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组·墓地选择1张符合条件且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34172284.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

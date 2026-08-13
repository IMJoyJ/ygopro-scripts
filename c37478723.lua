--『焔聖剣－デュランダル』
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡装备中的场合才能发动。从卡组把1只5星以下的战士族·炎属性怪兽加入手卡。那之后，这张卡破坏。
-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以自己墓地1只5星以下的战士族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
function c37478723.initial_effect(c)
	-- 对应“这张卡装备中的场合”中的“装备”：作为装备魔法卡发动，选择场上1只表侧表示怪兽，发动成功后将此卡装备给那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37478723.target)
	e1:SetOperation(c37478723.operation)
	c:RegisterEffect(e1)
	-- 对应“这张卡装备中的场合”中的“装备”：设置此卡作为装备卡时的装备对象限制（此处不限制对象，可装备给任意怪兽）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡装备中的场合才能发动。从卡组把1只5星以下的战士族·炎属性怪兽加入手卡。那之后，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37478723,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,37478723)
	e3:SetTarget(c37478723.thtg)
	e3:SetOperation(c37478723.thop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以自己墓地1只5星以下的战士族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37478723,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,37478723)
	e4:SetCondition(c37478723.spcon)
	e4:SetTarget(c37478723.sptg)
	e4:SetOperation(c37478723.spop)
	c:RegisterEffect(e4)
end
-- 发动条件与对象选择：确认自己或对方场上有表侧表示怪兽可作为装备对象；发动时选择其中1只表侧表示怪兽作为此卡的装备对象。
function c37478723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性判定：检查场上是否存在至少1只表侧表示怪兽可供选择作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示，要求选择要装备的怪兽卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上选择1只表侧表示怪兽，将其设为效果对象（取对象），并记录为连锁对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁包含装备卡效果，装备对象为此卡本身，用于后续效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡与选择的怪兽仍与效果关联且该怪兽仍表侧表示，则将此卡装备给那只怪兽。
function c37478723.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择作为装备对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备：将这张装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ①效果检索的过滤条件：卡组中的5星以下、战士族、炎属性且能够加入手卡的怪兽。
function c37478723.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(5) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息：检查卡组中是否存在符合条件的怪兽；设置检索加入手牌和破坏此卡的操作信息。
function c37478723.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：检查卡组中是否存在至少1张满足检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c37478723.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：此效果会从卡组将1张卡加入手牌（数量1，来源为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：此效果处理后会破坏此卡（这张装备卡）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ①效果处理：从卡组选择1只符合条件的怪兽加入手牌并向对方展示；若加入成功且该卡在手牌，则破坏这张装备卡。
function c37478723.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足检索条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c37478723.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若选择到的卡成功被加入持有者手牌（因效果送去手牌），则继续后续处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 将加入手牌的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsLocation(LOCATION_HAND) then
			-- 中断当前效果处理，使后续的装备卡破坏与检索入牌不在同一时点连锁处理（错开时点）。
			Duel.BreakEffect()
			-- 将这张装备卡破坏。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：此卡因装备怪兽被送去墓地而失去装备对象被送去墓地，且原装备怪兽现在在墓地。
function c37478723.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_GRAVE)
end
-- ②效果特殊召唤的过滤条件：自己墓地中的5星以下、战士族、炎属性，且可以被特殊召唤的怪兽。
function c37478723.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与对象选择：需要自己主要怪兽区有可用空位，并以自己墓地1只符合条件的怪兽为对象。
function c37478723.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37478723.spfilter(chkc,e,tp) end
	-- 发动合法性判定：确认自己的主要怪兽区存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性判定：确认自己墓地存在至少1只满足特殊召唤条件且可成为对象的怪兽。
		and Duel.IsExistingTarget(c37478723.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽，将其设为效果对象并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c37478723.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将选择的对象怪兽特殊召唤；随后给发动玩家附加直到回合结束不能特殊召唤非战士族怪兽的自肃效果。
function c37478723.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c37478723.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使其对玩家tp生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定条件：若怪兽不是战士族，则禁止特殊召唤。
function c37478723.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end

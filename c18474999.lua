--魔神儀－ブックストーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-能量石书本」以外的卡组1只「魔神仪」怪兽和手卡的这张卡特殊召唤。
-- ②：这张卡从卡组的特殊召唤成功的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
function c18474999.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-能量石书本」以外的卡组1只「魔神仪」怪兽和手卡的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18474999,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18474999)
	e1:SetCost(c18474999.spcost)
	e1:SetTarget(c18474999.sptg)
	e1:SetOperation(c18474999.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡从卡组的特殊召唤成功的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18474999,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,18474999)
	e2:SetCondition(c18474999.thcon)
	e2:SetTarget(c18474999.thtg)
	e2:SetOperation(c18474999.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c18474999.sumlimit)
	c:RegisterEffect(e3)
end
-- 筛选出卡组中满足「魔神仪」字段、卡名不是「魔神仪-能量石书本」、且可以被当前效果特殊召唤的怪兽。
function c18474999.filter(c,e,tp)
	return c:IsSetCard(0x117) and not c:IsCode(18474999) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选出自己手卡中非公开状态的仪式魔法卡，作为①效果发动时给对方观看的代价。
function c18474999.costfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and not c:IsPublic()
end
-- 效果①的发动代价处理：从手卡选择1张仪式魔法卡给对方确认，然后洗切手卡。
function c18474999.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己手卡是否存在1张符合条件的仪式魔法卡可供展示。
	if chk==0 then return Duel.IsExistingMatchingCard(c18474999.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求玩家选择一张给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手卡中选择1张符合条件的仪式魔法卡，作为展示代价。
	local g=Duel.SelectMatchingCard(tp,c18474999.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的仪式魔法卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手卡。
	Duel.ShuffleHand(tp)
end
-- 发动条件检测（chk==0）：己方不受『青眼精灵龙』的同时特殊召唤限制、主要怪兽区域空位足够、这张卡自身可特殊召唤，且卡组中存在可特殊召唤的「魔神仪」怪兽。
function c18474999.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 己方主要怪兽区域的可用空格数必须大于1，因为要同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 卡组中存在至少1只符合条件的「魔神仪」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c18474999.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行特殊召唤，预定数量为2，来源为手卡和卡组（目标在效果处理时确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①处理：确认这张卡仍与效果关联，且没有『青眼精灵龙』限制、空位足够后，从卡组选1只「魔神仪」怪兽与这张卡一起表侧表示特殊召唤。
function c18474999.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认己方主要怪兽区域至少有2个空格，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「魔神仪」怪兽，准备与这张卡一起特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c18474999.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将选出的「魔神仪」怪兽和这张卡一起表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 诱发条件：这张卡在特殊召唤成功之前位于卡组，即从卡组特殊召唤成功的场合。
function c18474999.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 筛选自己墓地中满足条件（仪式魔法卡且可以加入手卡）的卡。
function c18474999.thfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 效果②的发动条件与取对象：以自己墓地1张仪式魔法卡为对象，且该卡能够加入手卡。
function c18474999.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18474999.thfilter(chkc) end
	-- 发动合法性检测：自己墓地是否存在1张符合条件的仪式魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c18474999.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的仪式魔法卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c18474999.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向系统登记该对象卡将加入手卡，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理：取得对象卡，若仍与效果关联则将其加入持有者手卡。
function c18474999.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（即被选择的仪式魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 自肃判定：若尝试特殊召唤的怪兽来自额外卡组，则禁止该特殊召唤。
function c18474999.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end

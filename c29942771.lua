--ナチュル・カメリア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「自然」卡送去墓地。
-- ②：只要这张卡在怪兽区域存在，自己为让「自然」怪兽的效果发动而把怪兽解放的场合，可以作为代替从自己卡组上面把2张卡送去墓地。
-- ③：对方对怪兽的召唤·特殊召唤成功的场合才能发动。从自己墓地选1只「自然」怪兽特殊召唤。
function c29942771.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「自然」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29942771,0))  --"卡组「自然」卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,29942771)
	e1:SetTarget(c29942771.tgtg)
	e1:SetOperation(c29942771.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己为让「自然」怪兽的效果发动而把怪兽解放的场合，可以作为代替从自己卡组上面把2张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29942771,1))  --"是否使用「自然山茶」的效果代替解放？"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(29942771)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetCountLimit(1,29942772)
	c:RegisterEffect(e3)
	-- ③：对方对怪兽的召唤·特殊召唤成功的场合才能发动。从自己墓地选1只「自然」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29942771,2))  --"墓地「自然」怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,29942773)
	e4:SetCondition(c29942771.spcon)
	e4:SetTarget(c29942771.sptg)
	e4:SetOperation(c29942771.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 筛选卡组中满足『自然』字段且可以被效果送去墓地的卡。
function c29942771.tgfilter(c)
	return c:IsSetCard(0x2a) and c:IsAbleToGrave()
end
-- ①效果的发动时点判定：检查卡组是否存在符合条件的『自然』卡；满足后向对方提示已发动效果，并登记送去墓地的操作信息。
function c29942771.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：卡组中是否存在至少1张满足条件的『自然』卡（不取对象，效果处理时才选择要送去墓地的卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c29942771.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示本效果已发动，并展示对应的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记本次效果将把卡组中1张卡送去墓地的操作信息，用于连锁处理和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张满足条件的『自然』卡，选择到则将其以效果原因送去墓地。
function c29942771.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要送去墓地的卡，提示文字为『请选择要送去墓地的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组筛选出1张满足『自然』字段且可送去墓地的卡，供玩家选择。
	local g=Duel.SelectMatchingCard(tp,c29942771.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将玩家选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件判定：对方（1-tp）对怪兽的召唤或特殊召唤成功时，即存在召唤玩家为对方的怪兽时，本效果可以发动。
function c29942771.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 筛选墓地中满足『自然』字段且可以被玩家tp通过效果特殊召唤的怪兽。
function c29942771.spfilter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件与可处理性检查：自己主要怪兽区有空位，且墓地中至少存在1只符合条件的『自然』怪兽。
function c29942771.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查：墓地中是否存在至少1只满足『自然』字段且可特殊召唤的怪兽（不取对象，效果处理时选择）。
		and Duel.IsExistingMatchingCard(c29942771.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示已发动③效果，并展示对应的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记本次效果将从墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：若自己场上仍有主要怪兽区空格，则从墓地选择1只『自然』怪兽以表侧表示特殊召唤到自己场上。
function c29942771.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的主要怪兽区空格，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡，提示文字为『请选择要特殊召唤的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足『自然』字段且可特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c29942771.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，完成③效果的特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--白き森の妖魔ディアベル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用同调怪兽调整为素材作同调召唤的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡加入手卡。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己的额外卡组·墓地·除外状态的1只7星以下的同调怪兽调整特殊召唤。
local s,id,o=GetID()
-- 注册该怪兽的同调召唤手续以及①、②两个效果的发动条件、目标、cost和处理函数。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整和1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡用同调怪兽调整为素材作同调召唤的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己的额外卡组·墓地·除外状态的1只7星以下的同调怪兽调整特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤同调调整"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检查一张卡是否同时属于同调怪兽和调整，即是否为同调怪兽调整。
function s.cfilter(c)
	return bit.band(c:GetType(),TYPE_SYNCHRO+TYPE_TUNER)==TYPE_SYNCHRO+TYPE_TUNER
end
-- ①效果的发动条件：此卡为同调召唤成功，且其素材中存在同调怪兽调整。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and g:IsExists(s.cfilter,1,nil)
end
-- 定义可作为①效果对象的卡：我方墓地的魔法·陷阱卡，且能够加入手牌。
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果发动时的目标选择：从自己墓地的魔法·陷阱卡中选择1张作为对象，并设置将其加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己墓地是否存在至少1张满足条件的魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将1张卡加入手牌，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得对象卡，若仍与该效果关联，则将其加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的墓地卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：对方发动了魔法·陷阱·怪兽的效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义可作为②效果cost的卡：手牌·场上的魔法·陷阱卡，可作为cost送入墓地，并且存在符合条件的可特召同调调整且能腾出特召格子。
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		-- 额外确认：在额外卡组·墓地·除外区存在至少1只满足s.spfilter的同调怪兽调整，且以当前候选cost卡为基础计算特召空位仍然足够。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c)
end
-- ②效果的cost处理：从手牌·场上选择1张魔法·陷阱卡作为cost送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌·场上是否存在满足cost条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌·场上选择1张满足条件的魔法·陷阱卡作为cost。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选择的卡作为cost送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义②效果可特殊召唤的怪兽：7星以下的同调怪兽调整，能够被效果特殊召唤，并根据来源位置检查有足够空位。
function s.spfilter(c,e,tp,ec)
	return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevelBelow(7)
		-- 对于非额外卡组来源的候选卡：必须是表侧表示，并且在cost卡离场后主要怪兽区仍有空位可特召。
		and (not c:IsLocation(LOCATION_EXTRA) and c:IsFaceupEx() and Duel.GetMZoneCount(tp,ec)>0
			-- 对于额外卡组来源的候选卡：额外怪兽区/额外卡组特召区有足够的空位。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- ②效果的发动目标判断：不取对象，发动时直接合法，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从额外卡组·墓地·除外区特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理：从额外卡组·墓地·除外区选择1只符合条件的同调怪兽调整，表侧表示特殊召唤到自己的主要怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 使用过滤函数选择1只符合条件的同调怪兽调整（额外加入王家长眠之谷免疫过滤），来源为额外卡组·墓地·除外区。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

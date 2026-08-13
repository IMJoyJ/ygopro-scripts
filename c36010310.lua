--溟界の滓－ヌル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从卡组把1只爬虫类族·暗属性怪兽送去墓地。
-- ②：自己场上没有怪兽存在的场合或者有「溟界」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是爬虫类族怪兽不能特殊召唤。
function c36010310.initial_effect(c)
	-- ①：把这张卡从手卡送去墓地才能发动。从卡组把1只爬虫类族·暗属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36010310,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36010310)
	e1:SetCost(c36010310.tgcost)
	e1:SetTarget(c36010310.tgtg)
	e1:SetOperation(c36010310.tgop)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合或者有「溟界」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是爬虫类族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36010310,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36010311)
	e2:SetCondition(c36010310.spcon)
	e2:SetTarget(c36010310.sptg)
	e2:SetOperation(c36010310.spop)
	c:RegisterEffect(e2)
end
-- 作为①效果的发动代价，检查此卡能否从手卡送去墓地，并在发动时将其从手卡送去墓地。
function c36010310.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把发动效果的这张卡从手卡送去墓地，作为发动①效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义筛选条件：能够送去墓地、且为爬虫类族·暗属性的怪兽。
function c36010310.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- ①效果的目标阶段处理：确认卡组有符合条件的怪兽，并登记将卡组1张卡送去墓地的操作信息。
function c36010310.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只符合条件的爬虫类族·暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36010310.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果将把卡组的1张卡送去墓地，供连锁判定等系统参考。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时，从卡组选择1只符合条件的爬虫类族·暗属性怪兽送去墓地。
function c36010310.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示，提示正在选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组筛选并选择1张满足条件的爬虫类族·暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c36010310.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义筛选条件：怪兽需表侧表示且带有「溟界」字段。
function c36010310.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x161)
end
-- ②效果的发动条件：自己场上没有怪兽，或者自己场上有表侧表示的「溟界」怪兽。
function c36010310.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己怪兽区是否没有怪兽，或者存在表侧表示的「溟界」怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(c36010310.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标阶段：确认有可用怪兽区且此卡可被特殊召唤，并登记特殊召唤此卡的操作信息。
function c36010310.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区，以及墓地中的此卡是否能够被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果将特殊召唤此卡，供连锁判定等系统参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果关联，则将其从墓地特殊召唤；特殊召唤成功时，给它附加离场除外和只能特殊召唤爬虫类族怪兽的限制。
function c36010310.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行此卡的特殊召唤步骤，若成功则继续为它设置后续效果。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
			-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是爬虫类族怪兽不能特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetAbsoluteRange(tp,1,0)
			e2:SetTarget(c36010310.splimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
		-- 完成连续特殊召唤的处理，宣告本次特殊召唤正式结束。
		Duel.SpecialSummonComplete()
	end
end
-- 判断将要特殊召唤的怪兽是否不是爬虫类族，用于限制非爬虫类族怪兽的特殊召唤。
function c36010310.splimit(e,c)
	return not c:IsRace(RACE_REPTILE)
end

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
-- 支付将此卡从手卡送去墓地作为cost的处理
function c36010310.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡送去墓地作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索满足条件的爬虫类族·暗属性怪兽的过滤函数
function c36010310.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 设置效果处理时要送去墓地的卡的处理信息
function c36010310.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：自己卡组存在至少1张爬虫类族·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36010310.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要送去墓地的卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，选择并送去墓地满足条件的卡
function c36010310.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c36010310.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断场上是否有溟界怪兽的过滤函数
function c36010310.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x161)
end
-- 判断是否满足条件：自己场上没有怪兽或存在溟界怪兽
function c36010310.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足条件：自己场上没有怪兽或存在溟界怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(c36010310.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时要特殊召唤的卡的处理信息
function c36010310.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：自己场上存在空位且此卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时要特殊召唤的卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，特殊召唤此卡并设置其效果
function c36010310.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试特殊召唤此卡
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 此卡从场上离开时除外
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
			-- 只要此卡在场上存在，自己不能特殊召唤非爬虫类族怪兽
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
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 限制非爬虫类族怪兽特殊召唤的过滤函数
function c36010310.splimit(e,c)
	return not c:IsRace(RACE_REPTILE)
end

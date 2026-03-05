--DDラミア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把除「DD 拉弥亚」外的1张「DD」卡或「契约书」卡从自己的手卡·场上（表侧表示）送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19580308.initial_effect(c)
	-- 创建效果1，设置为起动效果，可以在手卡或墓地发动，一回合只能发动1次，需要支付代价并特殊召唤自己
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19580308,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,19580308)
	e1:SetCost(c19580308.cost)
	e1:SetTarget(c19580308.target)
	e1:SetOperation(c19580308.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「DD」卡或「契约书」卡作为代价
function c19580308.cfilter(c,ft)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0xaf,0xae)
		and not c:IsCode(19580308) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 检查是否满足发动条件，若满足则提示玩家选择一张卡送去墓地作为代价
function c19580308.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_HAND+LOCATION_ONFIELD
	if ft==0 then loc=LOCATION_MZONE end
	-- 判断是否有满足条件的卡可以作为代价
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c19580308.cfilter,tp,loc,0,1,nil,ft) end
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从满足条件的卡中选择一张卡送去墓地
	local g=Duel.SelectMatchingCard(tp,c19580308.cfilter,tp,loc,0,1,1,nil,ft)
	-- 将选择的卡送去墓地作为发动效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的目标，确认该卡可以被特殊召唤
function c19580308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果的处理，若成功特殊召唤则设置效果使该卡离场时除外
function c19580308.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，若成功则继续设置效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

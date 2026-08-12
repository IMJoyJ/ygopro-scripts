--青き眼の祭司
-- 效果：
-- 「青色眼睛的祭司」的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只光属性·1星调整为对象才能发动。那只怪兽加入手卡。
-- ②：让墓地的这张卡回到卡组，以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从自己墓地选那只怪兽以外的1只「青眼」怪兽特殊召唤。
function c45644898.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只光属性·1星调整为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45644898,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45644898.target)
	e1:SetOperation(c45644898.operation)
	c:RegisterEffect(e1)
	-- ②：让墓地的这张卡回到卡组，以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从自己墓地选那只怪兽以外的1只「青眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45644898,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,45644898)
	e2:SetCost(c45644898.spcost)
	e2:SetTarget(c45644898.sptg)
	e2:SetOperation(c45644898.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断是否为光属性、1星、调整类型的怪兽且能加入手牌
function c45644898.thfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 设置效果目标：选择满足条件的墓地调整怪兽作为目标
function c45644898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45644898.thfilter(chkc) end
	-- 检查是否满足发动条件：场上存在满足条件的墓地调整怪兽
	if chk==0 then return Duel.IsExistingTarget(c45644898.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地调整怪兽作为目标
	local g=Duel.SelectTarget(tp,c45644898.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将目标怪兽加入手牌
function c45644898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果发动的费用：将自身送入卡组
function c45644898.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将自身送入卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：判断是否为表侧表示、效果怪兽且能送去墓地
function c45644898.gvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
-- 过滤函数：判断是否为「青眼」怪兽且能特殊召唤
function c45644898.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择满足条件的场上效果怪兽作为目标
function c45644898.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45644898.gvfilter(chkc) end
	-- 检查是否满足发动条件：场上存在满足条件的场上效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c45644898.gvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否满足发动条件：场上存在可用区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查是否满足发动条件：墓地存在满足条件的「青眼」怪兽
		and Duel.IsExistingMatchingCard(c45644898.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的场上效果怪兽作为目标
	local g=Duel.SelectTarget(tp,c45644898.gvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果处理信息：从墓地特殊召唤1只「青眼」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：将目标怪兽送去墓地并特殊召唤「青眼」怪兽
function c45644898.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将目标怪兽送去墓地
		and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查是否满足发动条件：场上存在可用区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「青眼」怪兽作为特殊召唤目标
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45644898.spfilter),tp,LOCATION_GRAVE,0,1,1,tc,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「青眼」怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

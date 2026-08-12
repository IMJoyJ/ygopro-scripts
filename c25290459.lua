--レベルアップ！
-- 效果：
-- 把场上表侧表示存在的名字有「LV」的怪兽送去墓地发动。那张卡上面记述的怪兽，无视召唤条件从手卡·卡组特殊召唤。
function c25290459.initial_effect(c)
	-- 效果定义：将场上表侧表示存在的名字有「LV」的怪兽送去墓地发动。那张卡上面记述的怪兽，无视召唤条件从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25290459.cost)
	e1:SetTarget(c25290459.target)
	e1:SetOperation(c25290459.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上表侧表示存在的名字有「LV」的怪兽是否满足特殊召唤条件
function c25290459.costfilter(c,e,tp)
	if not c:IsSetCard(0x41) or not c:IsAbleToGraveAsCost() or c:IsFacedown() then return false end
	local code=c:GetOriginalCode()
	local class=_G["c"..code]
	if class==nil or class.lvup==nil then return false end
	-- 检查是否在手卡或卡组中存在可以被特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(c25290459.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,class,e,tp)
end
-- 过滤函数：检查手卡或卡组中是否包含与目标怪兽等级提升相关的怪兽
function c25290459.spfilter(c,class,e,tp)
	local code=c:GetCode()
	return c:IsCode(table.unpack(class.lvup)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果处理：选择场上表侧表示存在的名字有「LV」的怪兽送去墓地，并记录其卡号
function c25290459.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在名字有「LV」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25290459.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25290459.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
end
-- 效果处理：设置发动时的处理信息
function c25290459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	-- 设置操作信息：准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手卡或卡组特殊召唤符合条件的怪兽
function c25290459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件：场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local code=e:GetLabel()
	local class=_G["c"..code]
	if class==nil or class.lvup==nil then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25290459.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,class,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽无视召唤条件特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		-- 如果特殊召唤的怪兽来自卡组，则洗切卡组
		if tc:IsPreviousLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	end
end

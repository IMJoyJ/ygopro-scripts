--虚空海竜リヴァイエール
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己或对方的除外状态的1只4星以下的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c95992081.initial_effect(c)
	-- 添加超量召唤手续：用2只3星怪兽进行叠放。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己或对方的除外状态的1只4星以下的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(95992081,0))  --"特殊召唤"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95992081.cost)
	e1:SetTarget(c95992081.target)
	e1:SetOperation(c95992081.operation)
	c:RegisterEffect(e1)
end
-- 效果发动代价：取除这张卡的1个超量素材。
function c95992081.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：表侧表示、4星以下且可以特殊召唤的怪兽。
function c95992081.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动阶段：检查怪兽区域是否有空位，并选择1只符合条件的除外状态怪兽作为对象。
function c95992081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c95992081.filter(chkc,e,tp) end
	-- 检查自身场上是否有可以特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方的除外区是否存在满足条件的、可作为效果对象的怪兽。
		and Duel.IsExistingTarget(c95992081.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择双方除外区中1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c95992081.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：将选择的对象怪兽在自己场上特殊召唤。
function c95992081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

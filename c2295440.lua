--ワン・フォー・ワン
-- 效果：
-- ①：从手卡把1只怪兽送去墓地才能发动。从手卡·卡组把1只1星怪兽特殊召唤。
function c2295440.initial_effect(c)
	-- ①：从手卡把1只怪兽送去墓地才能发动。从手卡·卡组把1只1星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2295440.cost)
	e1:SetTarget(c2295440.target)
	e1:SetOperation(c2295440.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：选择1只怪兽作为从手卡送去墓地的cost，且该cost执行后手卡或卡组仍有可特殊召唤的1星怪兽。
function c2295440.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 追加条件：确认除了作为cost的这张卡以外，手卡或卡组存在可以特殊召唤的1星怪兽，以保证效果处理时有对象。
		and Duel.IsExistingMatchingCard(c2295440.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 定义特殊召唤对象的筛选条件：怪兽等级为1，并且能被当前效果特殊召唤（满足苏生限制、召唤条件等）。
function c2295440.filter(c,e,tp)
	return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价的声明阶段：用Label标记1表示需要先执行送墓cost，并允许发动；实际送墓操作在target阶段完成。
function c2295440.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动时的合法性检查和执行步骤：先确认有空格；若尚未执行cost则选择手牌1只怪兽送墓作为代价，然后设置从手卡·卡组特殊召唤1只1星怪兽的操作信息。
function c2295440.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查己方主要怪兽区是否有空位；若没有空位则无法发动或处理特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 在cost尚未执行时，确认手牌中存在至少1只满足cost条件的怪兽可供送去墓地。
			return Duel.IsExistingMatchingCard(c2295440.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		else
			-- 在cost已经执行后，确认手卡·卡组中存在至少1只可以特殊召唤的1星怪兽。
			return Duel.IsExistingMatchingCard(c2295440.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		-- 给玩家显示“请选择要送去墓地的卡”的提示信息，用于后续选择cost卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从手卡选择1只满足costfilter条件的怪兽，作为发动代价送去墓地。
		local g=Duel.SelectMatchingCard(tp,c2295440.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以代价原因（REASON_COST）送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	end
	-- 设置本次效果处理的操作信息：包含特殊召唤分类，预定从手卡·卡组特殊召唤1只怪兽，供相关卡牌和系统检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理阶段：确认空格后，从手卡·卡组选择1只1星怪兽，以表侧表示特殊召唤到自己场上。
function c2295440.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方主要怪兽区仍有空位；若无空位则直接结束，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组中选择1只满足filter条件的1星怪兽。
	local g=Duel.SelectMatchingCard(tp,c2295440.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示（正面守备表示？实际为正面表示）特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

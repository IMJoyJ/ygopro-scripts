--決戦の火蓋
-- 效果：
-- 可以把自己墓地1张怪兽卡从游戏中除外，从手卡把1只通常怪兽通常召唤。这个效果在自己回合的主要阶段时才能发动。
function c39712330.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 可以把自己墓地1张怪兽卡从游戏中除外，从手卡把1只通常怪兽通常召唤。这个效果在自己回合的主要阶段时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39712330,0))  --"通常召唤"
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c39712330.condition)
	e2:SetCost(c39712330.cost)
	e2:SetTarget(c39712330.target)
	e2:SetOperation(c39712330.activate)
	c:RegisterEffect(e2)
end
-- 效果发动条件：仅限自己回合的主要阶段（主要阶段1或主要阶段2），且当前回合玩家是效果控制者。
function c39712330.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家。
	local tn=Duel.GetTurnPlayer()
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	return tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤函数：墓地中可作为代价除外的怪兽卡（满足怪兽类型且能作为代价除外）。
function c39712330.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：检查墓地存在满足条件的怪兽，选择1张除外。
function c39712330.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：若墓地不存在满足条件的怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39712330.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片（效果提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c39712330.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：手牌中的通常怪兽，且能进行通常召唤或里侧守备表示通常召唤（Set）。
function c39712330.filter(c)
	return c:IsType(TYPE_NORMAL) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
end
-- 效果发动时选取对象（此处不取对象但确认手牌存在可通常召唤的通常怪兽），并设置操作信息。
function c39712330.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 统计手牌中满足条件的通常怪兽数量。
		local ct1=Duel.GetMatchingGroupCount(c39712330.filter,tp,LOCATION_HAND,0,nil)
		-- 获取本连锁已发动的该效果标识数量，用于限制可发动的次数。
		local ct2=Duel.GetFlagEffect(tp,39712330)
		return ct1-ct2>0
	end
	-- 登记一个标识效果，连锁结束重置，计数+1，用于防止同一连锁内重复结算。
	Duel.RegisterFlagEffect(tp,39712330,RESET_CHAIN,0,1)
	-- 设置操作信息为CATEGORY_SUMMON，表示效果处理时将进行通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：选择手牌中1只通常怪兽进行通常召唤（表侧攻击或里侧守备）。
function c39712330.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择手牌中1只满足条件的通常怪兽。
	local g=Duel.SelectMatchingCard(tp,c39712330.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		-- 如果该卡既能攻击表示也能里侧守备表示通常召唤，则让玩家选择表示形式；若不能里侧守备表示，则直接攻击表示召唤。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 通过效果进行表侧攻击表示的通常召唤（不占通常召唤次数）。
			Duel.Summon(tp,tc,true,nil)
		else
			-- 通过效果进行里侧守备表示的通常召唤（不占通常召唤次数）。
			Duel.MSet(tp,tc,true,nil)
		end
	end
end

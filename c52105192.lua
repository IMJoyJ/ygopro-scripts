--アームズ・ホール
-- 效果：
-- 这张卡发动的回合，自己不能通常召唤。
-- ①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
function c52105192.initial_effect(c)
	-- ①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c52105192.cost)
	e1:SetTarget(c52105192.target)
	e1:SetOperation(c52105192.activate)
	c:RegisterEffect(e1)
end
-- 代价处理：检查本回合是否尚未通常召唤且能将卡组顶1张作为代价送去墓地，然后执行丢弃卡组顶1张作为cost，并给己方附加本回合不能表侧通常召唤也不能里侧覆盖怪兽的誓约效果。
function c52105192.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：本回合自己尚未进行过通常召唤，并且自己能够把卡组最上面1张卡作为cost送去墓地时，才允许发动。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 and Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 将己方卡组最上面1张卡送去墓地，作为发动这张卡的代价（REASON_COST）。
	Duel.DiscardDeck(tp,1,REASON_COST)
	-- 这张卡发动的回合，自己不能通常召唤。①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 把禁止表侧表示通常召唤的效果注册给己方玩家，使其本回合不能进行表侧表示的通常召唤。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 把禁止里侧覆盖怪兽的效果注册给己方玩家，使其本回合也不能把怪兽里侧守备表示通常召唤（覆盖）。
	Duel.RegisterEffect(e2,tp)
end
-- 检索过滤条件：被选择的卡必须是装备魔法卡，并且能够加入手卡（没有受到使卡片不能加入手卡的限制）。
function c52105192.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 目标检查与操作信息设定：确认己方卡组·墓地存在满足条件的装备魔法卡，并设置本次效果要处理的操作信息为从卡组·墓地选1张卡加入手卡。
function c52105192.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：己方卡组·墓地中是否存在至少1张装备魔法卡且能够加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c52105192.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：声明本次效果将把1张卡从卡组·墓地加入手卡（用于后续连锁和效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从己方卡组·墓地选择1张符合条件的装备魔法卡加入手卡，并将该卡展示给对手确认。
function c52105192.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，要求其从符合条件的卡片中选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组·墓地中选择1张装备魔法卡，且该卡不受王家长眠之谷的影响（防止王谷无效从墓地加入手卡的效果）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52105192.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

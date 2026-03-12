--アームズ・ホール
-- 效果：
-- 这张卡发动的回合，自己不能通常召唤。
-- ①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
function c52105192.initial_effect(c)
	-- 效果原文内容：这张卡发动的回合，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c52105192.cost)
	e1:SetTarget(c52105192.target)
	e1:SetOperation(c52105192.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否满足发动条件，包括本回合未进行通常召唤且能支付将一张卡从卡组最上面送去墓地的代价。
function c52105192.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否满足发动条件，即本回合未进行通常召唤且能作为代价将一张卡从卡组最上面送去墓地。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 and Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 规则层面操作：将玩家的卡组最上面的一张卡送去墓地作为发动代价。
	Duel.DiscardDeck(tp,1,REASON_COST)
	-- 效果原文内容：①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 规则层面操作：将不能通常召唤的效果注册给全局环境，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 规则层面操作：将不能覆盖怪兽的效果注册给全局环境，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 规则层面操作：定义装备魔法卡的过滤条件，即为装备类型且能加入手牌。
function c52105192.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果原文内容：①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
function c52105192.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家在卡组和墓地中是否存在至少一张满足条件的装备魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c52105192.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 规则层面操作：设置连锁处理信息，表示将要处理的卡为1张来自卡组或墓地的装备魔法卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果原文内容：①：把卡组最上面的卡送去墓地才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
function c52105192.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：从卡组和墓地中选择一张满足条件的装备魔法卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52105192.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的装备魔法卡以效果原因加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认所选的装备魔法卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

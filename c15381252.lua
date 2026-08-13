--狂戦士の魂
-- 效果：
-- 「狂战士之魂」在1回合只能发动1张。
-- ①：自己场上的怪兽直接攻击给与对方1500以下的伤害时，把手卡全部丢弃才能发动。自己卡组最上面的卡翻开，那是怪兽的场合，那只怪兽送去墓地，给与对方500伤害。那之后，直到怪兽以外被翻开为止让这个效果重复（最多7次）。翻开的卡是怪兽以外的场合，那张卡回到卡组最上面。
function c15381252.initial_effect(c)
	-- 「狂战士之魂」在1回合只能发动1张。①：自己场上的怪兽直接攻击给与对方1500以下的伤害时，把手卡全部丢弃才能发动。自己卡组最上面的卡翻开，那是怪兽的场合，那只怪兽送去墓地，给与对方500伤害。那之后，直到怪兽以外被翻开为止让这个效果重复（最多7次）。翻开的卡是怪兽以外的场合，那张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCountLimit(1,15381252+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15381252.condition)
	e1:SetCost(c15381252.cost)
	e1:SetTarget(c15381252.target)
	e1:SetOperation(c15381252.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：确认本次战斗伤害是由自己场上怪兽直接攻击造成、对方受到1500以下伤害，且满足无攻击对象的直接攻击条件。
function c15381252.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 依次检查四个条件：受到伤害的是对方、造成伤害的怪兽控制者为自己、伤害数值不超过1500、攻击目标为空（即直接攻击）。
	return ep~=tp and eg:GetFirst():GetControler()==tp and ev<=1500 and Duel.GetAttackTarget()==nil
end
-- 代价函数：发动前检查手牌中除去本卡后是否仍有卡且全部可以丢弃；确认后实际将全部手牌丢弃作为发动代价。
function c15381252.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得发动者手牌中的全部卡，并移除本卡自身，用于检查是否存在可丢弃的手牌以及是否全部满足丢弃条件。
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return g:GetCount()>0 and g:FilterCount(Card.IsDiscardable,nil)==g:GetCount()
	end
	-- 再次取得发动者手牌中的全部卡，此时本卡已在场上发动，因此这些手牌就是要全部丢弃的代价对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将整个手牌组作为代价丢弃送入墓地，丢弃原因标记为代价与丢弃。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 目标函数：本效果发动时不取对象，只需确认自己卡组顶端有卡可被翻出并处理（即能否从卡组顶端丢弃卡）。
function c15381252.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段返回是否可以从卡组顶端丢弃1张卡，以此保证效果处理时能够翻卡并执行后续操作。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理函数：反复翻开卡组顶端，最多重复7次；每次翻到怪兽则将其送墓并给予500伤害，翻到非怪兽或无法继续时终止。
function c15381252.activate(e,tp,eg,ep,ev,re,r,rp)
	local count=8
	-- 循环继续条件：剩余重复次数大于0、自己卡组顶端仍能丢弃卡、对方LP仍大于0。
	while count>0 and Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetLP(1-tp)>0 do
		-- 从第2次重复开始中断当前效果处理，使每次翻卡、送墓和伤害作为独立连锁事件处理，避免时点被合并（对应“那之后”逐次重复）。
		if count<8 then Duel.BreakEffect() end
		-- 向双方玩家确认自己卡组最上方1张卡，将其公开。
		Duel.ConfirmDecktop(tp,1)
		-- 取得自己卡组最上方1张卡的组对象，用于判断翻开的是否为怪兽卡。
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 禁止这次从卡组取卡后触发自动洗牌检查，因为翻开的卡只是确认后置于原处或送墓，不应洗切卡组。
			Duel.DisableShuffleCheck()
			-- 如果翻开的卡是怪兽，则将其以效果送墓，并附带翻开（REASON_REVEAL）原因，供相关卡片连锁响应。
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
			if tc:IsLocation(LOCATION_GRAVE) then
				-- 对该卡的控制者的对方造成500点效果伤害。
				Duel.Damage(1-tp,500,REASON_EFFECT)
				count=count-1
			else count=0 end
		else
			count=0
		end
	end
end

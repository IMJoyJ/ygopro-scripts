--決闘塔アルカトラズ
-- 效果：
-- ①：自己·对方的战斗阶段开始时发动。双方各自可以从自身卡组选1只攻击力?以外的怪兽。选的怪兽给双方确认，里侧表示除外。选攻击力最高的怪兽的玩家可以从手卡把1只怪兽特殊召唤。这个效果特殊召唤的怪兽可以直接攻击。
-- ②：自己·对方的结束阶段才能发动。下次的自己回合的结束阶段有这张卡在场上存在的场合，场上的卡全部破坏。
function c43940008.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的战斗阶段开始时发动。双方各自可以从自身卡组选1只攻击力?以外的怪兽。选的怪兽给双方确认，里侧表示除外。选攻击力最高的怪兽的玩家可以从手卡把1只怪兽特殊召唤。这个效果特殊召唤的怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43940008,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c43940008.csop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段才能发动。下次的自己回合的结束阶段有这张卡在场上存在的场合，场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43940008,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(c43940008.dop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡是否为怪兽、攻击力不是?且可以被里侧表示除外，用于从卡组选出符合条件的怪兽。
function c43940008.csfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetTextAttack()>=0 and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 执行①效果：让双方各从卡组选1只攻击力?以外的怪兽，互相确认后里侧表示除外；再比较攻击力决定可特殊召唤的玩家，并由对应玩家从手卡特殊召唤1只怪兽，使其获得直接攻击效果。
function c43940008.csop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家发送“选择要除外的卡”的提示消息，用于后续卡组选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从自身卡组选择0或1只符合条件的怪兽（可跳过），返回所选卡或nil。
	local sc1=Duel.SelectMatchingCard(tp,c43940008.csfilter,tp,LOCATION_DECK,0,0,1,nil,tp):GetFirst()
	-- 给对手玩家发送“选择要除外的卡”的提示消息，用于后续卡组选择。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让对手玩家从自身卡组选择0或1只符合条件的怪兽，返回所选卡或nil。
	local sc2=Duel.SelectMatchingCard(1-tp,c43940008.csfilter,1-tp,LOCATION_DECK,0,0,1,nil,1-tp):GetFirst()
	if sc1 or sc2 then
		local p=0
		if (not sc2) or sc1 and sc1:GetTextAttack()>sc2:GetTextAttack() then p=tp
		elseif (not sc1) or sc1:GetTextAttack()<sc2:GetTextAttack() then p=1-tp
		else p=PLAYER_ALL end
		-- 将当前玩家选择的卡展示给对手确认，实现“给双方确认”。
		if sc1 then Duel.ConfirmCards(1-tp,sc1) end
		-- 将对手玩家选择的卡展示给当前玩家确认，实现“给双方确认”。
		if sc2 then Duel.ConfirmCards(tp,sc2) end
		-- 将双方选择的卡以里侧表示除外，处理原因为效果。
		Duel.Remove(Group.FromCards(sc1,sc2),POS_FACEDOWN,REASON_EFFECT)
		-- 判断当前玩家是否为攻击力最高的一方（或平局）且其怪兽区有空位，满足才可进行后续特殊召唤。
		if (p==tp or p==PLAYER_ALL) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查当前玩家手牌中是否存在可被特殊召唤的怪兽，作为特殊召唤的前提条件。
			and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false)
			-- 询问当前玩家是否从手卡特殊召唤1只怪兽（选择是/否）。
			and Duel.SelectYesNo(tp,aux.Stringid(43940008,2)) then  --"是否从手卡特殊召唤？"
			-- 给当前玩家发送“选择要特殊召唤的卡”的提示消息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从当前玩家手牌中选择1只可被特殊召唤的怪兽，返回该卡。
			local sc=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false):GetFirst()
			if sc then
				-- 将选择的怪兽以表侧表示特殊召唤到当前玩家场上。
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				-- 这个效果特殊召唤的怪兽可以直接攻击。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
		end
		-- 判断对手玩家是否为攻击力最高的一方（或平局）且其怪兽区有空位，满足才可进行后续特殊召唤。
		if (p==1-tp or p==PLAYER_ALL) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检查对手玩家手牌中是否存在可被特殊召唤的怪兽，作为特殊召唤的前提条件。
			and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,1-tp,LOCATION_HAND,0,1,nil,e,0,1-tp,false,false)
			-- 询问对手玩家是否从手卡特殊召唤1只怪兽（选择是/否）。
			and Duel.SelectYesNo(1-tp,aux.Stringid(43940008,2)) then  --"是否从手卡特殊召唤？"
			-- 给对手玩家发送“选择要特殊召唤的卡”的提示消息。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从对手玩家手牌中选择1只可被特殊召唤的怪兽，返回该卡。
			local sc=Duel.SelectMatchingCard(1-tp,Card.IsCanBeSpecialSummoned,1-tp,LOCATION_HAND,0,1,1,nil,e,0,1-tp,false,false):GetFirst()
			if sc then
				-- 将选择的怪兽以表侧表示特殊召唤到对手玩家场上。
				Duel.SpecialSummon(sc,0,1-tp,1-tp,false,false,POS_FACEUP)
				-- 这个效果特殊召唤的怪兽可以直接攻击。
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DIRECT_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
		end
	end
end
-- ②效果发动时的处理：根据发动时是否为自身回合计算目标结束阶段回合数，在这张卡上记录标记，并注册一个延迟效果，用于在条件满足时破坏场上所有卡。
function c43940008.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算从当前结束阶段到“下次的自己回合的结束阶段”需要的结束阶段次数：若当前是自己回合则为2，否则为1。
	local ct=Duel.GetTurnPlayer()==tp and 2 or 1
	c:RegisterFlagEffect(43940008,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,ct)
	-- 下次的自己回合的结束阶段有这张卡在场上存在的场合，场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	-- 给延迟效果设置标签，记录预定破坏发生的目标回合数（当前回合数+ct）。
	e1:SetLabel(Duel.GetTurnCount()+ct)
	e1:SetCountLimit(1)
	e1:SetCondition(c43940008.descon)
	e1:SetOperation(c43940008.desop)
	-- 将延迟效果注册到决斗中，使后续结束阶段能检查并执行破坏。
	Duel.RegisterEffect(e1,tp)
end
-- 延迟效果的发动条件：到达目标回合数，且这张卡仍在场上表侧表示且②已被发动过（有标记），才执行破坏。
function c43940008.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前是否为目标结束阶段，且此卡仍在场上并表侧表示。
	return Duel.GetTurnCount()==e:GetLabel() and c:IsOnField() and c:IsFaceup()
		and c:GetFlagEffect(43940008)>0
end
-- 执行破坏处理：将场上所有卡破坏。
function c43940008.desop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(0)
	-- 向双方玩家展示此卡，并播放发动的卡片动画/提示。
	Duel.Hint(HINT_CARD,0,43940008)
	-- 取得场上双方所有卡（含怪兽区与魔陷区、表侧与里侧）作为破坏对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将场上所有卡破坏，破坏原因为效果。
	Duel.Destroy(g,REASON_EFFECT)
end

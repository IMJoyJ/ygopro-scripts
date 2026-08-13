--インフェルニティ・リローダー
-- 效果：
-- 自己手卡是0张的场合，1回合1次，可以从自己卡组抽1张卡。这个效果抽到的卡给双方确认，怪兽卡的场合，给与对方基本分那只怪兽的等级×200的数值的伤害。魔法·陷阱卡的场合，自己受到500分伤害。
function c13582837.initial_effect(c)
	-- 自己手卡是0张的场合，1回合1次，可以从自己卡组抽1张卡。这个效果抽到的卡给双方确认，怪兽卡的场合，给与对方基本分那只怪兽的等级×200的数值的伤害。魔法·陷阱卡的场合，自己受到500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13582837,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c13582837.spcon)
	e1:SetTarget(c13582837.sptg)
	e1:SetOperation(c13582837.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：检查当前玩家tp的手卡数量是否为0。
function c13582837.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家tp的手牌区（LOCATION_HAND）卡数为0，作为效果可发动的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果发动目标函数：在发动时确认能否抽卡，并设置效果处理时的抽卡操作信息。
function c13582837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段（chk==0）返回当前玩家tp是否能抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息，表示本次效果处理将让tp从卡组抽1张卡（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
-- 效果处理函数：若自己手牌仍为0，从卡组顶抽1张卡并向对方确认，根据抽到的卡是怪兽或魔法陷阱分别造成伤害或自身受伤，最后洗切手牌。
function c13582837.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己手牌是否为0，若不为0则中止效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 then return end
	-- 取得卡组最上方1张卡作为预读取对象。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 以效果原因（REASON_EFFECT）让当前玩家tp抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		-- 将抽到的那张卡给对方玩家（1-tp）确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使后续伤害在不同时点处理，避免错过时点。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) then
			-- 若抽到的卡是怪兽，则给对手造成该怪兽等级×200的伤害。
			Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
		else
			-- 若抽到的卡不是怪兽（即魔法·陷阱），则自己受到500分伤害。
			Duel.Damage(tp,500,REASON_EFFECT)
		end
		-- 洗切手牌，重置手牌顺序的确认状态。
		Duel.ShuffleHand(tp)
	end
end

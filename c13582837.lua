--インフェルニティ・リローダー
-- 效果：
-- 自己手卡是0张的场合，1回合1次，可以从自己卡组抽1张卡。这个效果抽到的卡给双方确认，怪兽卡的场合，给与对方基本分那只怪兽的等级×200的数值的伤害。魔法·陷阱卡的场合，自己受到500分伤害。
function c13582837.initial_effect(c)
	-- 创建效果，设置效果描述为“抽卡”，效果类别为抽卡和伤害，效果类型为起动效果，限制每回合使用1次，效果适用区域为主怪区，效果发动条件为手牌数量为0，效果目标函数为sptg，效果处理函数为spop
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
-- 效果发动条件函数，检查当前玩家手牌数量是否为0
function c13582837.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家手牌数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果目标函数，用于判断是否可以发动效果
function c13582837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息，表示将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
-- 效果处理函数，用于执行效果处理逻辑
function c13582837.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查当前玩家手牌数量是否为0，若不为0则返回不执行效果
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 then return end
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 让玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		-- 给对方确认抽到的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) then
			-- 若抽到的卡为怪兽卡，则给与对方基本分该怪兽等级×200的伤害
			Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
		else
			-- 若抽到的卡为魔法或陷阱卡，则自己受到500分伤害
			Duel.Damage(tp,500,REASON_EFFECT)
		end
		-- 将玩家手牌洗切
		Duel.ShuffleHand(tp)
	end
end

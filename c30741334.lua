--熱血指導王ジャイアントレーナー
-- 效果：
-- 8星怪兽×3
-- 这个卡名的效果1回合可以使用最多3次，这个效果发动的回合，自己不能进行战斗阶段。
-- ①：把这张卡1个超量素材取除才能发动。自己抽1张，给双方确认。那是怪兽的场合，再给与对方800伤害。
function c30741334.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以任意3只8星怪兽叠放为素材进行XYZ召唤；nil表示素材怪兽无额外条件。
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合可以使用最多3次。①：把这张卡1个超量素材取除才能发动。自己抽1张，给双方确认。那是怪兽的场合，再给与对方800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(30741334,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(3,30741334)
	e1:SetCost(c30741334.cost)
	e1:SetTarget(c30741334.target)
	e1:SetOperation(c30741334.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查并实际执行移除1个超量素材，同时为自己附加本回合不能进入战斗阶段的誓约效果。
function c30741334.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定时，首先要求当前阶段为主要阶段1。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 这个效果发动的回合，自己不能进行战斗阶段。①：把这张卡1个超量素材取除才能发动。自己抽1张，给双方确认。那是怪兽的场合，再给与对方800伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将封印战斗阶段的誓约效果注册到场上，使其影响己方玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动时的目标判定与操作登记：确认自己可以抽1张卡，并登记本效果包含抽卡类别。
function c30741334.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否允许进行抽1张卡的效果抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 登记操作信息：本效果将让自己抽1张卡；抽到的卡在效果处理时才确定，因此对象设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：实际抽1张卡，若成功则给对方确认；若抽到的是怪兽，则中断效果后给与对方800点伤害；最后洗切手卡。
function c30741334.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让自己抽1张卡，并返回实际抽到的卡数。
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	-- 取得本次抽卡操作实际抽到的那张卡。
	local dc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的那张卡展示给对手确认。
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsType(TYPE_MONSTER) then
		-- 中断当前效果，使后续伤害处理与抽卡处理错开时点。
		Duel.BreakEffect()
		-- 以效果原因给与对方800点伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
	-- 洗切自己的手卡，防止因展示抽到的卡而暴露手牌顺序。
	Duel.ShuffleHand(tp)
end

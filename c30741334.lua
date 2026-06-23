--熱血指導王ジャイアントレーナー
-- 效果：
-- 8星怪兽×3
-- 这个卡名的效果1回合可以使用最多3次，这个效果发动的回合，自己不能进行战斗阶段。
-- ①：把这张卡1个超量素材取除才能发动。自己抽1张，给双方确认。那是怪兽的场合，再给与对方800伤害。
function c30741334.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为8、数量为3的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。自己抽1张，给双方确认。那是怪兽的场合，再给与对方800伤害。
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
-- 检查是否满足发动条件：当前阶段为主要阶段1且自身可以移除1个超量素材
function c30741334.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前阶段是否为主要阶段1
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 注册一个使自己不能进入战斗阶段的效果，持续到结束阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置效果的目标为玩家抽1张卡
function c30741334.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果操作：抽卡、确认卡片、若为怪兽则造成伤害
function c30741334.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从效果抽1张卡
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	-- 获取实际抽到的卡片
	local dc=Duel.GetOperatedGroup():GetFirst()
	-- 给对方确认抽到的卡片
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsType(TYPE_MONSTER) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 对对方造成800伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
	-- 将玩家手牌洗切
	Duel.ShuffleHand(tp)
end

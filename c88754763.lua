--CX 熱血指導神アルティメットレーナー
-- 效果：
-- 9星怪兽×4
-- 场上的这张卡不会成为卡的效果的对象。此外，这张卡有超量怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。从卡组抽1张卡，给双方确认。确认的卡是怪兽的场合，再给与对方基本分800分伤害。
function c88754763.initial_effect(c)
	-- 添加XYZ召唤手续：需要4只9星怪兽
	aux.AddXyzProcedure(c,nil,9,4)
	c:EnableReviveLimit()
	-- 场上的这张卡不会成为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 此外，这张卡有超量怪兽在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除才能发动。从卡组抽1张卡，给双方确认。确认的卡是怪兽的场合，再给与对方基本分800分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(88754763,0))  --"抽卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c88754763.condition)
	e2:SetCost(c88754763.cost)
	e2:SetTarget(c88754763.target)
	e2:SetOperation(c88754763.operation)
	c:RegisterEffect(e2)
end
-- 效果发动条件：检查这张卡是否有超量怪兽作为超量素材
function c88754763.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
-- 效果发动代价：取除这张卡的1个超量素材
function c88754763.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动目标：验证玩家是否可以抽卡，并设置抽卡操作信息
function c88754763.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查玩家当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的操作信息为抽卡，目标玩家为自己，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：抽1张卡并给双方确认，若确认的卡是怪兽卡，则再给予对方800分伤害，最后洗牌
function c88754763.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家因效果从卡组抽1张卡，并获取实际抽卡的数量
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	-- 获取刚才因抽卡操作加入手卡的那张卡
	local dc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡给对方玩家确认（即给双方确认）
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsType(TYPE_MONSTER) then
		-- 中断当前效果处理，使后续的伤害处理与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 给予对方玩家800分的效果伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end

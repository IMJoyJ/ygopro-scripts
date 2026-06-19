--CX 激烈華戦艦タオヤメ
-- 效果：
-- 4星怪兽×4
-- 对方的结束阶段时只有1次在对方手卡比自己手卡多的场合发动。对方选1张手卡丢弃。此外，这张卡有「烈华炮舰 抚子」在作为超量素材的场合，得到以下效果。
-- ●把这张卡1个超量素材取除才能发动。给与对方基本分场上的卡数量×300的数值的伤害。「混沌超量 激烈华战舰 手弱女」的这个效果1回合只能使用1次。
function c76419637.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽×4
	aux.AddXyzProcedure(c,nil,4,4)
	c:EnableReviveLimit()
	-- 对方的结束阶段时只有1次在对方手卡比自己手卡多的场合发动。对方选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76419637,0))
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c76419637.dccon)
	e1:SetTarget(c76419637.dctg)
	e1:SetOperation(c76419637.dcop)
	c:RegisterEffect(e1)
	-- 此外，这张卡有「烈华炮舰 抚子」在作为超量素材的场合，得到以下效果。●把这张卡1个超量素材取除才能发动。给与对方基本分场上的卡数量×300的数值的伤害。「混沌超量 激烈华战舰 手弱女」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76419637,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,76419637)
	e2:SetCondition(c76419637.damcon)
	e2:SetCost(c76419637.damcost)
	e2:SetTarget(c76419637.damtg)
	e2:SetOperation(c76419637.damop)
	c:RegisterEffect(e2)
end
-- 丢弃手牌效果的发动条件函数
function c76419637.dccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的结束阶段，且对方手牌数量大于自身手牌数量
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
end
-- 丢弃手牌效果的发动准备（设置目标玩家、参数及操作信息）
function c76419637.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的目标参数（丢弃数量）设置为1
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 丢弃手牌效果的执行函数
function c76419637.dcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令对方选择1张手牌因效果丢弃
	Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
-- 伤害效果的发动条件函数：检查超量素材中是否存在「烈华炮舰 抚子」
function c76419637.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,40424929)
end
-- 伤害效果的代价函数：取除这张卡的1个超量素材
function c76419637.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 伤害效果的发动准备（设置目标玩家及预估伤害的操作信息）
function c76419637.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上的卡片总数
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 将受到伤害的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的操作信息：给与对方场上卡片数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 伤害效果的执行函数
function c76419637.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（受到伤害的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前双方场上的卡片总数
	local ct=Duel.GetFieldGroupCount(p,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 给与目标玩家场上卡片数量×300的数值的伤害
	Duel.Damage(p,ct*300,REASON_EFFECT)
end

--サイレント・バーニング
-- 效果：
-- ①：自己场上有「沉默魔术师」怪兽存在，自己手卡比对方多的场合，自己·对方的战斗阶段才能发动（这张卡的发动和效果不会被无效化）。双方玩家各自直到手卡变成6张为止抽卡。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默魔术师」怪兽加入手卡。
function c44968459.initial_effect(c)
	-- ①：自己场上有「沉默魔术师」怪兽存在，自己手卡比对方多的场合，自己·对方的战斗阶段才能发动（这张卡的发动和效果不会被无效化）。双方玩家各自直到手卡变成6张为止抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44968459,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44968459.condition)
	e1:SetTarget(c44968459.target)
	e1:SetOperation(c44968459.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默魔术师」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44968459,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果②的发动代价为把墓地中的这张卡除外（aux.bfgcost封装了除外自身作为cost的操作）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44968459.thtg)
	e2:SetOperation(c44968459.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：判断怪兽是否为表侧表示且属于「沉默魔术师」字段（0xe8），用于检查自己场上是否存在符合条件的「沉默魔术师」怪兽。
function c44968459.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe8)
end
-- 效果①的发动条件：自己手牌数大于对方手牌数，当前处于战斗阶段（PHASE_BATTLE_START到PHASE_BATTLE之间），且自己场上有表侧表示的「沉默魔术师」怪兽存在。
function c44968459.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己（tp）手牌区的卡牌数量。
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 获取对方（以tp视角看对方）手牌区的卡牌数量。
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return ct1>ct2 and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		-- 检查自己场上（主要怪兽区域）是否存在至少1张满足cfilter条件的「沉默魔术师」怪兽。
		and Duel.IsExistingMatchingCard(c44968459.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动时的目标处理：分别计算双方手牌距离6张所需抽卡数，确认双方都能抽这些数量的卡，并在发动时设定抽卡类别及数量的操作信息。
function c44968459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己需要抽的卡数：6减去自己当前手牌数。
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 计算对方需要抽的卡数：6减去对方当前手牌数。
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 发动合法性检查：确认自己需要抽的卡数大于0，且自己可以抽ct1张卡。
	if chk==0 then return ct1>0 and Duel.IsPlayerCanDraw(tp,ct1)
		-- 发动合法性检查：确认对方需要抽的卡数大于0，且对方可以抽ct2张卡。
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2) end
	-- 设定本连锁的操作信息：包含抽卡效果，对自己玩家tp预期抽ct1张卡（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
	-- 设定本连锁的操作信息：包含抽卡效果，对对方玩家1-tp预期抽ct2张卡（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
end
-- 效果①的实际处理：重新计算双方各自需要抽到6张手牌的卡数，然后让双方玩家各自抽相应数量的卡。
function c44968459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新计算自己当前需要抽的卡数。
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 处理时重新计算对方当前需要抽的卡数。
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ct1>0 then
		-- 让自己玩家tp以效果原因抽ct1张卡。
		Duel.Draw(tp,ct1,REASON_EFFECT)
	end
	if ct2>0 then
		-- 让对方玩家1-tp以效果原因抽ct2张卡。
		Duel.Draw(1-tp,ct2,REASON_EFFECT)
	end
end
-- 定义检索过滤器：对象必须是「沉默魔术师」字段（0xe8）的怪兽卡，且可以被加入手牌。
function c44968459.thfilter(c)
	return c:IsSetCard(0xe8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②发动时的目标处理：确认卡组中存在至少1只符合条件的「沉默魔术师」怪兽，并设定操作信息为从卡组将1张卡加入手牌。
function c44968459.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认自己卡组中存在至少1张满足thfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44968459.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定本连锁的操作信息：包含回手牌效果，预期从卡组将1张卡加入持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的实际处理：从卡组选择1只「沉默魔术师」怪兽加入手牌，并向对方展示加入手牌的卡。
function c44968459.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己卡组选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c44968459.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家（1-tp）确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

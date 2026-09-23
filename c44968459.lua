--サイレント・バーニング
-- 效果：
-- ①：自己场上有「沉默魔术师」怪兽存在，自己手卡比对方多的场合，自己·对方的战斗阶段才能发动（这张卡的发动和效果不会被无效化）。双方玩家各自直到手卡变成6张为止抽卡。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默魔术师」怪兽加入手卡。
function c44968459.initial_effect(c)
	-- ①：自己场上有「沉默魔术师」怪兽存在，自己手卡比对方多的场合，自己·对方的战斗阶段才能发动。双方玩家各自直到手卡变成6张为止抽卡。
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
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「沉默魔术师」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44968459,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44968459.thtg)
	e2:SetOperation(c44968459.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的「沉默魔术师」怪兽
function c44968459.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe8)
end
-- 效果发动条件：处于战斗阶段、自己手卡多于对方且场上有「沉默魔术师」怪兽
function c44968459.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡数量
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 获取对方手卡数量
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ct1>ct2 and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		-- 检查自己场上是否存在表侧表示的「沉默魔术师」怪兽
		and Duel.IsExistingMatchingCard(c44968459.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动检查与确认双方抽卡数量
function c44968459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己需要抽卡的数量（抽至6张）
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 计算对方需要抽卡的数量（抽至6张）
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 确认自己手卡少于6张且能够抽卡
	if chk==0 then return ct1>0 and Duel.IsPlayerCanDraw(tp,ct1)
		-- 确认对方手卡少于6张且能够抽卡
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2) end
	-- 设置操作信息：自己抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
	-- 设置操作信息：对方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
end
-- 效果处理：双方各自直到手卡变成6张为止抽卡
function c44968459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己需要抽卡的数量
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 计算对方需要抽卡的数量
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ct1>0 then
		-- 自己抽卡直到手卡变成6张
		Duel.Draw(tp,ct1,REASON_EFFECT)
	end
	if ct2>0 then
		-- 对方抽卡直到手卡变成6张
		Duel.Draw(1-tp,ct2,REASON_EFFECT)
	end
end
-- 过滤卡组中可以加入手卡的「沉默魔术师」怪兽
function c44968459.thfilter(c)
	return c:IsSetCard(0xe8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动检查与设置操作信息：从卡组将怪兽加入手卡
function c44968459.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以加入手卡的「沉默魔术师」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44968459.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只「沉默魔术师」怪兽加入手卡
function c44968459.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「沉默魔术师」怪兽
	local g=Duel.SelectMatchingCard(tp,c44968459.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

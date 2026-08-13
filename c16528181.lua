--王の棺
-- 效果：
-- 这个卡名的②的效果1回合可以使用最多4次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「荷鲁斯」怪兽不会被不以自身为对象的卡的效果破坏。
-- ②：把1张手卡送去墓地才能发动。从卡组把1只「荷鲁斯」怪兽送去墓地。
-- ③：1回合1次，自己的「荷鲁斯」怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽送去墓地。
function c16528181.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「荷鲁斯」怪兽不会被不以自身为对象的卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetValue(c16528181.efilter)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16528181.intg)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合可以使用最多4次。②：把1张手卡送去墓地才能发动。从卡组把1只「荷鲁斯」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(4,16528181)
	e2:SetCost(c16528181.cost)
	e2:SetTarget(c16528181.target)
	e2:SetOperation(c16528181.activate)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己的「荷鲁斯」怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16528181,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16528181.descon)
	e3:SetTarget(c16528181.destg)
	e3:SetOperation(c16528181.desop)
	c:RegisterEffect(e3)
end
-- 判定对象是否为表侧表示的「荷鲁斯」怪兽，作为①效果的适用对象筛选。
function c16528181.intg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x19d)
end
-- ①效果的保护判定：若破坏效果不以该卡为对象则免疫；若以该卡为对象则不保护（即“不被不以自身为对象的卡的效果破坏”的具体实现）。
function c16528181.efilter(e,re,rp,c)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁效果的对象卡组，用于判断该效果是否以受保护的荷鲁斯怪兽为对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(c)
end
-- ②效果的发动代价：从手卡丢弃1张卡作为代价，并检查是否满足该代价。
function c16528181.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手卡是否存在至少1张可作为代价送去墓地的卡，用于决定②效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行②效果的代价：从手卡选择1张卡以COST理由丢弃。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 定义②效果送墓对象的筛选条件：卡组中的「荷鲁斯」怪兽且能够被送去墓地。
function c16528181.filter(c)
	return c:IsSetCard(0x19d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动条件与目标设定：确认卡组中存在符合条件的荷鲁斯怪兽；同时登记效果处理时从卡组送墓的操作信息。
function c16528181.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只符合筛选条件的「荷鲁斯」怪兽，作为②效果的发动前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c16528181.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息，声明本次效果处理预计从卡组把1张卡送去墓地（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：由玩家从卡组选择1只符合条件的「荷鲁斯」怪兽并送去墓地。
function c16528181.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字“请选择要送去墓地的卡”，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张符合条件的「荷鲁斯」怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c16528181.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「荷鲁斯」怪兽以效果（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件：己方场上有表侧表示的「荷鲁斯」怪兽与对方怪兽进行战斗，且对方怪兽仍与战斗相关。
function c16528181.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方正在战斗中的那只怪兽。
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsSetCard(0x19d)) then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- ③效果的发动阶段设定：暂存战斗的对方怪兽，并确认其可作为“送去墓地”的对象；同时登记操作信息。
function c16528181.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 登记操作信息，声明本次效果将把暂存的对方怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,bc,1,0,0)
end
-- ③效果处理：若对方怪兽仍在战斗且控制者仍为对方，则将其送入墓地。
function c16528181.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() then
		-- 将对方怪兽以效果（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(bc,REASON_EFFECT)
	end
end

--煉獄の消華
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把「炼狱的消华」以外的1张「炼狱」魔法·陷阱卡加入手卡。这个效果的发动后，直到回合结束时自己不是「狱火机」怪兽不能召唤·特殊召唤。
-- ②：自己的「狱火机」怪兽和对方怪兽进行战斗的伤害计算后，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那些进行战斗的双方怪兽除外。
function c78748366.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡才能发动。从卡组把「炼狱的消华」以外的1张「炼狱」魔法·陷阱卡加入手卡。这个效果的发动后，直到回合结束时自己不是「狱火机」怪兽不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78748366,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,78748366)
	e2:SetCost(c78748366.thcost)
	e2:SetTarget(c78748366.thtg)
	e2:SetOperation(c78748366.thop)
	c:RegisterEffect(e2)
	-- ②：自己的「狱火机」怪兽和对方怪兽进行战斗的伤害计算后，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那些进行战斗的双方怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c78748366.cost)
	e3:SetTarget(c78748366.target)
	e3:SetOperation(c78748366.operation)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价：丢弃1张手卡。
function c78748366.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「炼狱的消华」以外的「炼狱」魔法·陷阱卡。
function c78748366.thfilter(c)
	return c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(78748366) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组中是否存在可检索的卡，并设置检索的操作信息。
function c78748366.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「炼狱」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c78748366.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为“从卡组将1张卡加入手卡”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将过滤的卡加入手卡，并对自身施加“不是「狱火机」怪兽不能召唤·特殊召唤”的限制。
function c78748366.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「炼狱」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c78748366.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「狱火机」怪兽不能召唤·特殊召唤。/②：自己的「狱火机」怪兽和对方怪兽进行战斗的伤害计算后，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那些进行战斗的双方怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c78748366.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“不能召唤「狱火机」以外的怪兽”的限制效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册“不能特殊召唤「狱火机」以外的怪兽”的限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤·特殊召唤的怪兽不能是「狱火机」以外的怪兽。
function c78748366.sumlimit(e,c)
	return not c:IsSetCard(0xbb)
end
-- 效果②的发动代价：将魔法与陷阱区域表侧表示的这张卡送去墓地。
function c78748366.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备：获取进行战斗的双方怪兽，确认是否满足除外条件，并设置除外的操作信息。
function c78748366.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if chk==0 then return a and d and a:IsSetCard(0xbb) and (a:IsAbleToRemove() or d:IsAbleToRemove()) end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if d:IsRelateToBattle() then g:AddCard(d) end
	-- 设置连锁处理中的操作信息为“将进行战斗的双方怪兽除外”。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果②的效果处理：将进行战斗且仍存在于场上的双方怪兽除外。
function c78748366.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将进行战斗的双方怪兽表侧表示除外。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end

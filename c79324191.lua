--隠密忍法帖
-- 效果：
-- ①：1回合1次，从手卡把1只「忍者」怪兽送去墓地才能发动。从卡组选「隐密忍法帖」以外的1张「忍法」魔法·陷阱卡在自己场上盖放。
function c79324191.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从手卡把1只「忍者」怪兽送去墓地才能发动。从卡组选「隐密忍法帖」以外的1张「忍法」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79324191,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c79324191.setcost)
	e2:SetTarget(c79324191.settg)
	e2:SetOperation(c79324191.setop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可作为代价送去墓地的「忍者」怪兽
function c79324191.costfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价：从手卡将1只「忍者」怪兽送去墓地
function c79324191.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为代价送去墓地的「忍者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79324191.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌选择1只满足条件的「忍者」怪兽
	local g=Duel.SelectMatchingCard(tp,c79324191.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中「隐密忍法帖」以外的、可盖放的「忍法」魔法·陷阱卡
function c79324191.setfilter(c)
	return c:IsSetCard(0x61) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(79324191) and c:IsSSetable()
end
-- 效果发动的目标：检查卡组中是否存在可盖放的「忍法」魔法·陷阱卡
function c79324191.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「忍法」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79324191.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果运行：从卡组选1张「忍法」魔法·陷阱卡在自己场上盖放
function c79324191.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张满足条件的「忍法」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c79324191.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end

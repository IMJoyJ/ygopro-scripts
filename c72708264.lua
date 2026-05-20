--EMボットアイズ・リザード
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，从卡组把1只「异色眼」怪兽送去墓地才能发动。直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
function c72708264.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，从卡组把1只「异色眼」怪兽送去墓地才能发动。直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72708264,0))  --"变成同名卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c72708264.copycon)
	e1:SetCost(c72708264.copycost)
	e1:SetOperation(c72708264.copyop)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否在召唤·特殊召唤成功的回合
function c72708264.copycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 过滤卡组中可以作为代价送去墓地的「异色眼」怪兽
function c72708264.costfilter(c)
	return c:IsSetCard(0x99) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从卡组把1只「异色眼」怪兽送去墓地，并记录该怪兽的卡号
function c72708264.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以作为代价送去墓地的「异色眼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72708264.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只「异色眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c72708264.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
end
-- 效果处理：使这张卡直到结束阶段当作送去墓地的怪兽的同名卡使用，并注册一个在结束阶段重置该效果的延迟效果
function c72708264.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	-- 直到结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72708264,1))  --"变成同名卡的效果结束"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	e2:SetOperation(c72708264.rstop)
	c:RegisterEffect(e2)
end
-- 结束阶段重置同名卡效果的处理
function c72708264.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 选中这张卡并显示选中动画，提示玩家该卡的效果发生变化
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示该卡同名化效果已结束
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end

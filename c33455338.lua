--邪狂神の使い
-- 效果：
-- 对方的准备阶段时只有1次，可以把自己墓地存在的暗属性怪兽任意数量从游戏中除外。直到结束阶段时，这张卡的守备力上升这个效果除外的怪兽数量×500的数值。
function c33455338.initial_effect(c)
	-- 对方的准备阶段时只有1次，可以把自己墓地存在的暗属性怪兽任意数量从游戏中除外。直到结束阶段时，这张卡的守备力上升这个效果除外的怪兽数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33455338,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c33455338.atkcon)
	e1:SetCost(c33455338.atkcost)
	e1:SetOperation(c33455338.atkop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：当前回合玩家不是本卡的控制者，即仅在对方准备阶段时效果才满足发动条件。
function c33455338.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不等于效果发动者tp，以此确认处于对方的准备阶段。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义可供除外的卡片筛选条件：该卡必须是暗属性怪兽，且可以作为代价从墓地除外。
function c33455338.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 定义发动效果时的代价：在墓地存在至少1张符合条件的暗属性怪兽时，从自己墓地将任意数量（1张以上）的暗属性怪兽选择除外，并记录实际除外的数量作为后续守备力上升的依据。
function c33455338.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测步骤：当chk==0时，检查自己墓地是否存在至少1张满足条件的暗属性怪兽，用于判定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c33455338.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，要求玩家从墓地中选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1至99张符合条件的暗属性怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c33455338.filter,tp,LOCATION_GRAVE,0,1,99,nil)
	e:SetLabel(g:GetCount())
	-- 将选择的一组卡以表侧表示从游戏中除外，作为发动效果所支付的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若这张卡仍在场上且表侧表示，则给它赋予一个直到结束阶段有效的守备力提升效果，提升数值为效果发动时除外的怪兽数量×500。
function c33455338.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到结束阶段时，这张卡的守备力上升这个效果除外的怪兽数量×500的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(e:GetLabel()*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

--邪狂神の使い
-- 效果：
-- 对方的准备阶段时只有1次，可以把自己墓地存在的暗属性怪兽任意数量从游戏中除外。直到结束阶段时，这张卡的守备力上升这个效果除外的怪兽数量×500的数值。
function c33455338.initial_effect(c)
	-- 创建一个字段诱发即时效果，用于在对方准备阶段发动，效果描述为攻击上升
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
-- 效果发动条件：当前回合玩家不是效果使用者
function c33455338.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否与效果使用者不同
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：用于筛选墓地中的暗属性可除外怪兽
function c33455338.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果发动费用：检查使用者墓地是否存在暗属性怪兽，若有则选择任意数量从游戏中除外
function c33455338.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查使用者墓地是否存在至少1张满足条件的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33455338.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示使用者选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的暗属性怪兽，数量为1到99张
	local g=Duel.SelectMatchingCard(tp,c33455338.filter,tp,LOCATION_GRAVE,0,1,99,nil)
	e:SetLabel(g:GetCount())
	-- 将选择的怪兽从游戏中除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：使自身守备力上升除外怪兽数量×500的数值，持续到结束阶段
function c33455338.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使自身守备力上升除外怪兽数量×500的数值，持续到结束阶段
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(e:GetLabel()*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

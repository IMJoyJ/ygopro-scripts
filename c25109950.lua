--アイルの小剣士
-- 效果：
-- 每用自己场上存在的这张卡以外的1只怪兽做祭品，这张卡的攻击力在回合结束前加700。
function c25109950.initial_effect(c)
	-- 效果原文内容：每用自己场上存在的这张卡以外的1只怪兽做祭品，这张卡的攻击力在回合结束前加700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25109950,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c25109950.atkcost)
	e1:SetOperation(c25109950.atkop)
	c:RegisterEffect(e1)
end
-- 检查并选择1张满足条件的怪兽进行解放作为代价。
function c25109950.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张可解放的怪兽（不包括自身）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 从玩家场上选择1张满足条件的怪兽进行解放。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 将选中的怪兽进行解放，作为效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 效果处理函数，用于提升攻击力。
function c25109950.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使这张卡的攻击力上升700，回合结束时消失。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

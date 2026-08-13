--アイルの小剣士
-- 效果：
-- 每用自己场上存在的这张卡以外的1只怪兽做祭品，这张卡的攻击力在回合结束前加700。
function c25109950.initial_effect(c)
	-- 每用自己场上存在的这张卡以外的1只怪兽做祭品，这张卡的攻击力在回合结束前加700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25109950,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c25109950.atkcost)
	e1:SetOperation(c25109950.atkop)
	c:RegisterEffect(e1)
end
-- 发动前选定代价：从自己场上选择这张卡以外的1只怪兽解放，作为发动效果的代价。
function c25109950.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：在发动确认阶段，检测自己场上是否存在这张卡以外的1只可解放的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 选择代价对象：从自己场上这张卡以外的可解放怪兽中，选择1只作为祭品。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 执行解放：将选择的怪兽作为代价解放，送入墓地。
	Duel.Release(g,REASON_COST)
end
-- 效果处理：若这张卡仍在场上且表侧表示，并且与发动时的效果仍有关联，则赋予其攻击力上升700的效果，持续到回合结束。
function c25109950.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力在回合结束前加700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

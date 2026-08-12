--ダーク・エンジェル
-- 效果：
-- ①：自己的天使族怪兽被选择作为攻击对象时，把那只怪兽解放，把这张卡从手卡送去墓地，以自己场上1只表侧表示怪兽为对象才能发动。攻击对象转移为那只自己怪兽，作为对象的怪兽的攻击力直到回合结束时上升解放的天使族怪兽的原本攻击力数值。
function c28593329.initial_effect(c)
	-- 创建效果，设置为场上的诱发选发效果，满足条件时可以发动，将自身从手卡发动并解放攻击对象的天使族怪兽，将攻击对象转移给场上一只自己怪兽，使该怪兽攻击力上升解放怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28593329,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c28593329.cost)
	e1:SetTarget(c28593329.target)
	e1:SetOperation(c28593329.activate)
	c:RegisterEffect(e1)
end
-- 支付效果代价：将攻击对象的天使族怪兽解放，将自身从手卡送去墓地。
function c28593329.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击对象
	local at=Duel.GetAttackTarget()
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		and at and at:IsControler(tp) and at:IsRace(RACE_FAIRY) and at:IsReleasable() end
	e:SetLabel(at:GetBaseAttack())
	-- 将攻击对象的天使族怪兽解放作为代价
	Duel.Release(at,REASON_COST)
	-- 将自身从手卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 选择效果的对象：选择自己场上一只表侧表示的怪兽作为攻击对象转移的目标。
function c28593329.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击对象
	local at=Duel.GetAttackTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=at end
	-- 判断是否满足选择对象的条件：场上存在一只自己表侧表示的怪兽且不是攻击对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,at) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只自己场上表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,at)
end
-- 发动效果：将攻击对象转移给选择的怪兽，并给该怪兽加上攻击力提升效果。
function c28593329.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		-- 将攻击对象转移为选择的怪兽
		Duel.ChangeAttackTarget(tc)
		-- 给选择的怪兽加上攻击力提升效果，提升数值为解放的天使族怪兽的原本攻击力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

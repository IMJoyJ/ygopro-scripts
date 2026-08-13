--デーモン・カオス・キング
-- 效果：
-- 恶魔族调整＋调整以外的怪兽1只以上
-- 这张卡的攻击宣言时，可以让对方场上表侧表示存在的全部怪兽的攻击力·守备力直到战斗阶段结束时交换。
function c36407615.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以1只恶魔族调整为调整素材，加上调整以外的怪兽1只以上作为非调整素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡的攻击宣言时，可以让对方场上表侧表示存在的全部怪兽的攻击力·守备力直到战斗阶段结束时交换。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36407615,0))  --"攻守交换"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c36407615.attg)
	e1:SetOperation(c36407615.atop)
	c:RegisterEffect(e1)
end
-- 筛选条件：怪兽为表侧表示，且守备力不低于0（即所有表侧表示怪兽均满足）。
function c36407615.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 发动目标判定函数：确认对方场上是否存在至少1只表侧表示怪兽，作为效果可否发动的条件。
function c36407615.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查（chk==0）是否存在至少1只对方场上表侧表示的怪兽，若存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c36407615.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理操作：获取对方场上所有表侧表示怪兽，逐只记录其当前攻击力和守备力，然后互相赋值，完成攻击力与守备力的交换，持续到战斗阶段结束。
function c36407615.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件（表侧表示）的怪兽，形成临时组g。
	local g=Duel.GetMatchingGroup(c36407615.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 攻击力·守备力直到战斗阶段结束时交换（攻击力部分：将攻击力改为原本守备力）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		-- 攻击力·守备力直到战斗阶段结束时交换（守备力部分：将守备力改为原本攻击力）。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end

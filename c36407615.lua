--デーモン・カオス・キング
-- 效果：
-- 恶魔族调整＋调整以外的怪兽1只以上
-- 这张卡的攻击宣言时，可以让对方场上表侧表示存在的全部怪兽的攻击力·守备力直到战斗阶段结束时交换。
function c36407615.initial_effect(c)
	-- 添加同调召唤手续，要求1只恶魔族调整和1只以上调整以外的怪兽作为素材
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
-- 定义过滤函数，用于筛选场上表侧表示且守备力大于等于0的怪兽
function c36407615.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 设置效果的target函数，检查对方场上是否存在满足条件的怪兽
function c36407615.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果发动条件，即对方场上存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36407615.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果发动时执行的操作，将对方场上所有满足条件的怪兽的攻守值互换
function c36407615.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的怪兽组成Group
	local g=Duel.GetMatchingGroup(c36407615.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 将怪兽的攻击力设置为原本的守备力，直到战斗阶段结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		-- 将怪兽的守备力设置为原本的攻击力，直到战斗阶段结束时重置
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end

--BF－熱風のギブリ
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。这张卡的原本的攻击力·守备力直到回合结束时交换。
function c26775203.initial_effect(c)
	-- 效果原文内容：①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26775203,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c26775203.condition)
	e1:SetTarget(c26775203.target)
	e1:SetOperation(c26775203.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，自己主要阶段才能发动。这张卡的原本的攻击力·守备力直到回合结束时交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26775203,1))  --"原本的攻击力·守备力交换"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c26775203.adchange)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否满足效果发动条件，即攻击方不是自己且没有攻击目标。
function c26775203.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前正在攻击的怪兽。
	local at=Duel.GetAttacker()
	-- 规则层面作用：判断攻击方不是自己并且没有攻击目标。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 规则层面作用：设置特殊召唤的处理信息，确定目标为自身。
function c26775203.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 规则层面作用：检查场上是否有足够的空间进行特殊召唤，并且自身可以被特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 规则层面作用：设置连锁操作信息，表示将要特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 规则层面作用：执行特殊召唤操作，将自身从手牌特殊召唤到场上。
function c26775203.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面作用：将卡牌特殊召唤到场上，使用正面表示形式。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 规则层面作用：交换自身原本的攻击力和守备力。
function c26775203.adchange(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local batk=c:GetBaseAttack()
	local bdef=c:GetBaseDefense()
	-- 规则层面作用：设置攻击力为原本的守备力值，并在回合结束时重置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
	e1:SetValue(bdef)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
	e2:SetValue(batk)
	c:RegisterEffect(e2)
end

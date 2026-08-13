--BF－熱風のギブリ
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。这张卡的原本的攻击力·守备力直到回合结束时交换。
function c26775203.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
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
	-- ②：1回合1次，自己主要阶段才能发动。这张卡的原本的攻击力·守备力直到回合结束时交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26775203,1))  --"原本的攻击力·守备力交换"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c26775203.adchange)
	c:RegisterEffect(e2)
end
-- 发动条件：对方怪兽的直接攻击宣言。此处检查攻击者为对方怪兽（控制者与当前玩家不同）且攻击目标为空（直接攻击）。
function c26775203.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	-- 确认攻击怪兽为对方所控制（1-tp），且没有攻击对象（Duel.GetAttackTarget()==nil），即满足“对方怪兽的直接攻击宣言”的条件。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果发动时的目标合法性检查：自己场上存在可用的主要怪兽区空格，且这张卡可以被特殊召唤；若满足则登记特殊召唤的操作信息。
function c26775203.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查自己场上是否有可用的主要怪兽区空格，并且此卡是否满足被特殊召唤的条件（不无视召唤条件和苏生限制）。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置本次连锁的特殊召唤操作信息：预定将这张卡特殊召唤1张（target_player=0表示由效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理时，若这张卡仍与当前效果关联，则将其特殊召唤；否则不处理。
function c26775203.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到当前玩家tp的场上，sumtype=0，不无视召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 交换此卡的原本攻击力与原本守备力直到回合结束：通过附加两个临时效果分别将原本攻击力/守备力改为另一项的值。
function c26775203.adchange(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local batk=c:GetBaseAttack()
	local bdef=c:GetBaseDefense()
	-- 这张卡的原本的攻击力·守备力直到回合结束时交换。
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

--クロス・アタック
-- 效果：
-- 选择自己场上表侧攻击表示存在的2只持有相同攻击力的怪兽发动。这个回合，选择的1只怪兽可以直接攻击对方玩家。另1只怪兽不能攻击。
function c46961802.initial_effect(c)
	-- 选择自己场上表侧攻击表示存在的2只持有相同攻击力的怪兽发动。这个回合，选择的1只怪兽可以直接攻击对方玩家。另1只怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46961802,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果的发动条件为只能在主要阶段或战斗阶段（满足aux.bpcon条件）时发动。
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c46961802.target)
	e1:SetOperation(c46961802.activate)
	c:RegisterEffect(e1)
end
-- 定义filter1：选择候选怪兽时，要求该怪兽是表侧攻击表示，且场上还存在另一只表侧攻击表示并与之攻击力相同的怪兽（由filter2判断）。
function c46961802.filter1(c,tp)
	-- 返回条件：c自身是表侧攻击表示，并且场上存在至少1只除c以外的、攻击表示且攻击力等于c攻击力的怪兽。
	return c:IsAttackPos() and Duel.IsExistingTarget(c46961802.filter2,tp,LOCATION_MZONE,0,1,c,c:GetAttack())
end
-- 定义filter2：判断目标怪兽c是否为表侧攻击表示，且攻击力等于指定的atk值（即与第一只选择怪兽攻击力相同）。
function c46961802.filter2(c,atk)
	return c:IsAttackPos() and c:IsAttack(atk)
end
-- 定义tgfilter：筛选自己场上所有表侧攻击表示且能够成为该效果对象的怪兽，用于目标选择候选。
function c46961802.tgfilter(c,e)
	return c:IsAttackPos() and c:IsCanBeEffectTarget(e)
end
-- 定义gcheck：检查SelectSubGroup当前已选择的怪兽组g中，第一只与第二只怪兽的攻击力是否相同；相同则认可本次选择。
function c46961802.gcheck(g)
	return g:GetFirst():GetAttack()==g:GetNext():GetAttack()
end
-- 效果发动时的目标选择处理：先判断是否存在合法对象；存在则获取所有可被取对象的攻击表示怪兽，通过SelectSubGroup让玩家选出2只攻击力相同的怪兽，并将它们设为效果对象。
function c46961802.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判定（chk==0）：检查是否存在至少1只自己场上表侧攻击表示且能满足与其他攻击表示怪兽攻击力相同条件的怪兽，以此作为效果能否发动的依据。
	if chk==0 then return Duel.IsExistingTarget(c46961802.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 获取自己场上所有表侧攻击表示且能被效果取对象的怪兽组g，作为后续选择2只相同攻击力怪兽的候选池。
	local g=Duel.GetMatchingGroup(c46961802.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 向玩家发送选择目标的提示消息（请选择效果的对象），并让玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c46961802.gcheck,false,2,2)
	-- 将选择好的2只怪兽设置为当前连锁的效果对象，供后续效果处理时使用。
	Duel.SetTargetCard(sg)
end
-- 效果处理：从连锁中取出对象怪兽；若对象不足2只则终止执行；由玩家选择其中1只作为可直接攻击的怪兽，另1只作为不能攻击的怪兽；随后分别给它们赋予直接攻击和不能攻击的效果。
function c46961802.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁效果相关的对象怪兽（即发动时选择并登记的两只怪兽）。
	local g=Duel.GetTargetsRelateToChain()
	if #g<2 then return end
	-- 向玩家发送提示消息（请选择可以直接攻击的怪兽），并让玩家从两只对象中选择1只。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(46961802,1))  --"请选择可以直接攻击的怪兽"
	local tc1=g:Select(tp,1,1,nil):GetFirst()
	local tc2=(g-tc1):GetFirst()
	-- 这个回合，选择的1只怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc1:RegisterEffect(e1)
	-- 另1只怪兽不能攻击。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc2:RegisterEffect(e2)
end

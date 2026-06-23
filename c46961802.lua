--クロス・アタック
-- 效果：
-- 选择自己场上表侧攻击表示存在的2只持有相同攻击力的怪兽发动。这个回合，选择的1只怪兽可以直接攻击对方玩家。另1只怪兽不能攻击。
function c46961802.initial_effect(c)
	-- 创建效果对象并设置其描述、类型、属性、触发条件、目标函数和发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46961802,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果发动的时点条件为可以进行战斗操作的阶段
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c46961802.target)
	e1:SetOperation(c46961802.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足攻击表示且存在相同攻击力怪兽作为目标的怪兽
function c46961802.filter1(c,tp)
	-- 判断当前怪兽是否处于攻击表示并是否存在具有相同攻击力的其他怪兽
	return c:IsAttackPos() and Duel.IsExistingTarget(c46961802.filter2,tp,LOCATION_MZONE,0,1,c,c:GetAttack())
end
-- 过滤满足攻击表示且攻击力等于指定值的怪兽
function c46961802.filter2(c,atk)
	return c:IsAttackPos() and c:IsAttack(atk)
end
-- 过滤满足攻击表示且可以成为效果对象的怪兽
function c46961802.tgfilter(c,e)
	return c:IsAttackPos() and c:IsCanBeEffectTarget(e)
end
-- 检查怪兽组中两个怪兽的攻击力是否相等
function c46961802.gcheck(g)
	return g:GetFirst():GetAttack()==g:GetNext():GetAttack()
end
-- 选择满足条件的2只怪兽作为效果对象
function c46961802.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件，即场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c46961802.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 获取所有可以成为效果对象的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c46961802.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c46961802.gcheck,false,2,2)
	-- 将选中的怪兽组设置为效果的目标
	Duel.SetTargetCard(sg)
end
-- 处理效果发动后执行的操作，包括选择直接攻击和不能攻击的怪兽
function c46961802.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的怪兽组
	local g=Duel.GetTargetsRelateToChain()
	if #g<2 then return end
	-- 提示玩家选择可以直接攻击的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(46961802,1))  --"请选择可以直接攻击的怪兽"
	local tc1=g:Select(tp,1,1,nil):GetFirst()
	local tc2=(g-tc1):GetFirst()
	-- 使选中的怪兽获得直接攻击对方玩家的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc1:RegisterEffect(e1)
	-- 使另一只选中的怪兽失去攻击能力
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc2:RegisterEffect(e2)
end

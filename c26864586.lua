--共振装置
-- 效果：
-- 选择自己场上表侧表示存在的2只相同种族·属性的怪兽发动。选择的1只怪兽的等级直到结束阶段时变成和另1只怪兽的等级相同。
function c26864586.initial_effect(c)
	-- 选择自己场上表侧表示存在的2只相同种族·属性的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26864586.target)
	e1:SetOperation(c26864586.activate)
	c:RegisterEffect(e1)
end
-- 过滤出场上表侧表示且等级大于等于1的怪兽，且可以成为效果对象的怪兽
function c26864586.tgfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
-- 检查所选怪兽组是否满足等级各不相同、属性相同、种族相同的要求
function c26864586.gcheck(g)
	-- 检查所选怪兽组是否满足等级各不相同、属性相同、种族相同的要求
	return aux.dlvcheck(g) and aux.SameValueCheck(g,Card.GetAttribute) and aux.SameValueCheck(g,Card.GetRace)
end
-- 检索满足条件的2只怪兽组作为效果对象
function c26864586.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c26864586.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c26864586.gcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c26864586.gcheck,false,2,2)
	-- 将选中的怪兽组设置为效果对象
	Duel.SetTargetCard(tg)
end
-- 处理效果的发动，将选中的怪兽等级调整为与另一只怪兽相同
function c26864586.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的怪兽组
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	if g:GetFirst():GetLevel()==g:GetNext():GetLevel() then return end
	-- 提示玩家选择等级要变化的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26864586,0))  --"请选择等级要变化的怪兽"
	local tc2=g:Select(tp,1,1,nil):GetFirst()
	local tc1=(g-tc2):GetFirst()
	local lv=tc1:GetLevel()
	-- 选择的1只怪兽的等级直到结束阶段时变成和另1只怪兽的等级相同
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc2:RegisterEffect(e1)
end

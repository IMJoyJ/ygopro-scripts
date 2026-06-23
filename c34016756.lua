--フォース
-- 效果：
-- ①：以场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的攻击力变成一半，另1只怪兽的攻击力上升那个数值。
function c34016756.initial_effect(c)
	-- ①：以场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的攻击力变成一半，另1只怪兽的攻击力上升那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34016756.target)
	e1:SetOperation(c34016756.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回满足条件的表侧表示怪兽且可以成为效果对象的卡
function c34016756.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 检查组中是否存在至少1张攻击力大于等于1的怪兽
function c34016756.gcheck(g)
	return g:IsExists(Card.IsAttackAbove,1,nil,1)
end
-- 效果处理函数，选择2只满足条件的怪兽作为对象
function c34016756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c34016756.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(c34016756.gcheck,2,2) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c34016756.gcheck,false,2,2)
	-- 将选中的怪兽设置为效果对象
	Duel.SetTargetCard(tg)
end
-- 发动效果函数，处理攻击力变化
function c34016756.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的怪兽组
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	-- 向玩家提示“请选择攻击力变成一半的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34016756,0))  --"请选择攻击力变成一半的怪兽"
	local tc1=g:FilterSelect(tp,Card.IsAttackAbove,1,1,nil,1):GetFirst()
	local tc2=(g-tc1):GetFirst()
	local atk=tc1:GetAttack()
	-- 将对象怪兽的攻击力变为原来的一半
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(atk/2))
	if tc1:RegisterEffect(e1) then
		-- 将另一只对象怪兽的攻击力上升原来的一半
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(math.ceil(atk/2))
		tc2:RegisterEffect(e2)
	end
end

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
-- 筛选场上表侧表示且能够成为此效果对象的怪兽。
function c34016756.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 检查所选2只怪兽中是否存在至少1只攻击力在1以上，以保证有怪兽可作为攻击力减半的对象。
function c34016756.gcheck(g)
	return g:IsExists(Card.IsAttackAbove,1,nil,1)
end
-- 发动时的目标选择处理：获取场上符合条件的表侧表示怪兽，要求选择2张且其中至少有1张攻击力在1以上，选择后将其设为效果对象。
function c34016756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方场上所有表侧表示且能成为此效果对象的怪兽集合。
	local g=Duel.GetMatchingGroup(c34016756.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(c34016756.gcheck,2,2) end
	-- 向玩家显示“请选择效果的对象”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c34016756.gcheck,false,2,2)
	-- 将所选两张怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(tg)
end
-- 效果处理时：从与连锁相关的对象中，选择1只攻击力在1以上的怪兽作为攻击力减半对象，另1只作为上升对象；对减半对象赋予“攻击力变成一半”的效果，若成功则对另一只赋予上升相同数值的效果。
function c34016756.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择且仍与连锁相关的对象怪兽。
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	-- 向玩家显示“请选择攻击力变成一半的怪兽”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34016756,0))  --"请选择攻击力变成一半的怪兽"
	local tc1=g:FilterSelect(tp,Card.IsAttackAbove,1,1,nil,1):GetFirst()
	local tc2=(g-tc1):GetFirst()
	local atk=tc1:GetAttack()
	-- 作为对象的1只怪兽的攻击力变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(atk/2))
	if tc1:RegisterEffect(e1) then
		-- 另1只怪兽的攻击力上升那个数值。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(math.ceil(atk/2))
		tc2:RegisterEffect(e2)
	end
end

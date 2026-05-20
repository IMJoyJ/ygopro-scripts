--トロイボム
-- 效果：
-- 自己场上的怪兽的控制权被对方的卡的效果转移给对方玩家时才能发动。那1只怪兽破坏，给与对方基本分那个攻击力数值的伤害。
function c63323539.initial_effect(c)
	-- 自己场上的怪兽的控制权被对方的卡的效果转移给对方玩家时才能发动。那1只怪兽破坏，给与对方基本分那个攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CONTROL_CHANGED)
	e1:SetTarget(c63323539.target)
	e1:SetOperation(c63323539.operation)
	c:RegisterEffect(e1)
end
-- 过滤当前控制权在对方场上且可以成为效果对象的怪兽
function c63323539.filter(c,e,tp)
	return c:IsControler(1-tp) and c:IsCanBeEffectTarget(e)
end
-- 检查是否因对方卡片效果导致控制权转移，并确认是否存在符合条件的怪兽作为发动条件和效果对象
function c63323539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c63323539.filter(chkc,e,tp) end
	if chk==0 then return r==REASON_EFFECT and rp==1-tp
		and eg:IsExists(c63323539.filter,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local g=eg:FilterSelect(tp,c63323539.filter,1,1,nil,e,tp)
	-- 将选择的怪兽设置为效果处理对象
	Duel.SetTargetCard(g)
	-- 设置操作信息：破坏选中的那1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与对方玩家等同于该怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果处理：获取目标怪兽，将其破坏并给与对方其攻击力数值的伤害
function c63323539.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local atk=tc:GetAttack()
	if atk<0 or tc:IsFacedown() then atk=0 end
	-- 以效果原因破坏目标怪兽，并检查是否成功破坏
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 以效果原因给与对方玩家等同于该怪兽攻击力数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end

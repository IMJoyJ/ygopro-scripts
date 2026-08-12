--分断の壁
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的全部攻击表示怪兽的攻击力下降对方场上的怪兽数量×800。
function c58169731.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的全部攻击表示怪兽的攻击力下降对方场上的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c58169731.condition)
	e1:SetTarget(c58169731.target)
	e1:SetOperation(c58169731.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，判断是否在对方怪兽攻击宣言时发动
function c58169731.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前进行攻击宣言的怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：筛选表侧攻击表示的怪兽
function c58169731.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 定义效果发动时的目标确认函数
function c58169731.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58169731.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 定义效果处理函数，计算下降数值并依次降低对方场上所有表侧攻击表示怪兽的攻击力
function c58169731.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足表侧攻击表示条件的怪兽
	local g=Duel.GetMatchingGroup(c58169731.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 计算攻击力下降的数值，即对方场上的怪兽数量乘以800
	local atk=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*800
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部攻击表示怪兽的攻击力下降对方场上的怪兽数量×800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

--アマゾネスの弩弓隊
-- 效果：
-- 只有在对方进行攻击宣言，且自己场上存在名称中含有「亚马逊」字样的怪兽时这张卡才能发动。将对方场上所有怪兽都变成表向攻击表示（此时反转不发动），攻击力下降500点。对方所有的怪兽都必须进行攻击。
function c67987611.initial_effect(c)
	-- 只有在对方进行攻击宣言，且自己场上存在名称中含有「亚马逊」字样的怪兽时这张卡才能发动。将对方场上所有怪兽都变成表向攻击表示（此时反转不发动），攻击力下降500点。对方所有的怪兽都必须进行攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c67987611.condition)
	e1:SetTarget(c67987611.target)
	e1:SetOperation(c67987611.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「亚马逊」怪兽
function c67987611.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 发动条件：对方回合且自己场上存在「亚马逊」怪兽
function c67987611.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合（对方进行攻击宣言），且自己场上是否存在表侧表示的「亚马逊」怪兽
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(c67987611.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：非表侧攻击表示的怪兽
function c67987611.filter(c)
	return not c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果发动：设置改变表示形式的操作信息
function c67987611.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有非表侧攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c67987611.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：改变对方场上非表侧攻击表示怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将对方怪兽变为表侧攻击表示，降低攻击力并强制攻击
function c67987611.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有非表侧攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c67987611.filter,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上所有非表侧攻击表示的怪兽变成表侧攻击表示（不触发反转效果）
	Duel.ChangePosition(g,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	-- 获取对方场上所有表侧表示的怪兽
	local fg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=fg:GetFirst()
	while tc do
		-- 攻击力下降500点
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方所有的怪兽都必须进行攻击
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_MUST_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=fg:GetNext()
	end
end

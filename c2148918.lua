--機甲忍法ラスト・ミスト
-- 效果：
-- 自己场上有名字带有「忍者」的怪兽存在，对方场上有怪兽特殊召唤时，那些特殊召唤的怪兽的攻击力变成一半。
function c2148918.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，当对方怪兽特殊召唤时发动，效果描述为攻击变化
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2148918,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c2148918.spcon)
	e2:SetTarget(c2148918.sptg)
	e2:SetOperation(c2148918.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查自己场上是否存在表侧表示的「忍者」卡
function c2148918.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 过滤函数，检查目标怪兽是否为表侧表示且为对方控制
function c2148918.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and (not e or c:IsRelateToEffect(e))
end
-- 效果条件函数，判断对方有怪兽特殊召唤且自己场上存在「忍者」卡
function c2148918.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方有怪兽特殊召唤且自己场上存在「忍者」卡
	return eg:IsExists(c2148918.tgfilter,1,nil,nil,1-tp) and Duel.IsExistingMatchingCard(c2148918.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，设置连锁目标为所有特殊召唤的怪兽
function c2148918.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将所有特殊召唤的怪兽设置为连锁处理对象
	Duel.SetTargetCard(eg)
end
-- 效果处理函数，将符合条件的怪兽攻击力变为一半
function c2148918.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c2148918.tgfilter,nil,e,1-tp)
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽的攻击力变为一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

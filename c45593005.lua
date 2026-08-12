--D・マグネンI
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：自己场上有这张卡以外的怪兽表侧攻击表示2只存在的场合，1回合1次，可以让这张卡的攻击力直到这个回合的结束阶段时上升那些怪兽的攻击力的合计数值。这个效果发动的回合，其他怪兽不能攻击。
-- ●守备表示：只要这张卡在场上表侧表示存在，自己场上存在的怪兽不能攻击。
function c45593005.initial_effect(c)
	-- 创建一个永续效果，用于处理攻击表示时的攻击力上升效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45593005,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c45593005.cona)
	e1:SetTarget(c45593005.tga)
	e1:SetOperation(c45593005.opa)
	c:RegisterEffect(e1)
	-- 创建一个永续效果，用于处理守备表示时的不能攻击效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c45593005.cond)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否为表侧攻击表示
function c45593005.cfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 效果发动条件：自身为攻击表示且自己场上存在2只其他表侧攻击表示怪兽，且没有表侧守备表示怪兽
function c45593005.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
		-- 检查自己场上是否存在2只其他表侧攻击表示怪兽
		and Duel.GetMatchingGroupCount(c45593005.cfilter,tp,LOCATION_MZONE,0,e:GetHandler())==2
		-- 检查自己场上是否存在表侧守备表示怪兽
		and not Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果处理函数，设置连锁对象为所有场上表侧表示怪兽，并创建不能攻击效果
function c45593005.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	-- 将场上所有表侧表示怪兽设置为连锁对象
	Duel.SetTargetCard(g)
	-- 创建一个字段效果，使所有怪兽不能攻击，除了自身以外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c45593005.ftarget)
	e1:SetLabel(c:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的不能攻击效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 目标函数，用于判断目标怪兽是否为自身
function c45593005.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且与效果相关
function c45593005.filter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理函数，计算目标怪兽攻击力总和并提升自身攻击力
function c45593005.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c45593005.filter,nil,e)
	if sg:GetCount()==0 then return end
	local atk=sg:GetSum(Card.GetAttack)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 创建一个单体效果，用于提升自身攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自身为守备表示
function c45593005.cond(e)
	return e:GetHandler():IsDefensePos()
end

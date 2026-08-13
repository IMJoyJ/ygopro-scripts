--D・マグネンI
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：自己场上有这张卡以外的怪兽表侧攻击表示2只存在的场合，1回合1次，可以让这张卡的攻击力直到这个回合的结束阶段时上升那些怪兽的攻击力的合计数值。这个效果发动的回合，其他怪兽不能攻击。
-- ●守备表示：只要这张卡在场上表侧表示存在，自己场上存在的怪兽不能攻击。
function c45593005.initial_effect(c)
	-- 攻击表示效果：自己场上有这张卡以外的怪兽表侧攻击表示2只存在的场合，1回合1次，可以让这张卡的攻击力直到这个回合的结束阶段时上升那些怪兽的攻击力的合计数值。这个效果发动的回合，其他怪兽不能攻击。
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
	-- 守备表示效果：只要这张卡在场上表侧表示存在，自己场上存在的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c45593005.cond)
	c:RegisterEffect(e2)
end
-- 怪兽筛选条件：该怪兽是表侧表示且为攻击表示，用于判断“这张卡以外的怪兽表侧攻击表示”。
function c45593005.cfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 攻击表示效果的发动条件判定：自身未被无效且为攻击表示；自己场上有这张卡以外的表侧攻击表示怪兽正好2只；且自己场上不存在其他表侧守备表示怪兽。
function c45593005.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
		-- 统计自己场上除这张卡以外的表侧攻击表示怪兽数量，要求恰好为2只。
		and Duel.GetMatchingGroupCount(c45593005.cfilter,tp,LOCATION_MZONE,0,e:GetHandler())==2
		-- 确认自己场上除这张卡以外不存在任何表侧守备表示的怪兽。
		and not Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 目标设定：效果发动时，将场上除自身以外的所有表侧表示怪兽设为对象（用于计算攻击力合计），并登记一个本回合内其他怪兽不能攻击的誓约效果。
function c45593005.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 取得自己场上除这张卡以外的所有表侧表示怪兽，作为攻击力上升所参照的“那些怪兽”。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	-- 将选中的怪兽组设为当前连锁的对象，以便效果处理时获取；同时这些卡成为效果的对象。
	Duel.SetTargetCard(g)
	-- 对应攻击表示效果中“其他怪兽不能攻击”的誓约以及处理时攻击力上升：发动后，本回合除这张卡以外的自己怪兽不能攻击；处理时这张卡攻击力上升那些怪兽攻击力的合计。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c45593005.ftarget)
	e1:SetLabel(c:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的誓约效果注册到场上，使其在本回合内持续适用于自己场上的其他怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- “其他怪兽”的判定条件：若怪兽的FieldID不等于效果Label中记录的这张卡的FieldID，说明它不是发动效果的这张卡自身，则受不能攻击效果限制。
function c45593005.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果处理时的怪兽筛选：必须是表侧表示且仍与当前效果有关联的怪兽，即那些仍可用于计算攻击力上升的怪兽。
function c45593005.filter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理操作：从当前连锁对象中筛出仍合法且表侧表示的对象怪兽，计算它们的攻击力合计；若自身仍与效果相关且表侧表示，则将上升该数值的效果赋予自身。
function c45593005.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的对象卡组，即发动时通过Duel.SetTargetCard设置的怪兽组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c45593005.filter,nil,e)
	if sg:GetCount()==0 then return end
	local atk=sg:GetSum(Card.GetAttack)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 攻击力上升效果：这张卡的攻击力直到这个回合的结束阶段时上升那些怪兽的攻击力的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 守备表示效果的适用条件：这张卡以表侧守备表示存在，此时适用于“自己场上存在的怪兽不能攻击”的效果。
function c45593005.cond(e)
	return e:GetHandler():IsDefensePos()
end

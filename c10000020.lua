--オシリスの天空竜
-- 效果：
-- 这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
-- ③：这张卡的攻击力·守备力上升自己手卡数量×1000。
-- ④：每次对方场上有怪兽攻击表示召唤·特殊召唤发动。那些怪兽的攻击力下降2000。变成0的场合那怪兽破坏。
-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
function c10000020.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000020,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000020.ttcon)
	e1:SetOperation(c10000020.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000020.setcon)
	c:RegisterEffect(e2)
	-- ①：这张卡的召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000020.sumsuc)
	c:RegisterEffect(e4)
	-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(10000020,0))  --"送去墓地"
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCondition(c10000020.tgcon)
	e5:SetTarget(c10000020.tgtg)
	e5:SetOperation(c10000020.tgop)
	c:RegisterEffect(e5)
	-- ③：这张卡的攻击力·守备力上升自己手卡数量×1000。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(c10000020.adval)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
	-- ④：每次对方场上有怪兽攻击表示召唤·特殊召唤发动。那些怪兽的攻击力下降2000。变成0的场合那怪兽破坏。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(10000020,1))  --"攻击下降"
	e8:SetCategory(CATEGORY_ATKCHANGE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetTarget(c10000020.atktg)
	e8:SetOperation(c10000020.atkop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e9)
end
-- 检查是否满足解放3只怪兽进行上级召唤的条件
function c10000020.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查场上是否存在至少3只怪兽可作为解放的祭品
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 执行解放3只怪兽进行上级召唤的操作
function c10000020.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3只怪兽作为解放的祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的3只祭品怪兽解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 限制这张卡不能进行通常召唤的放置（盖卡）
function c10000020.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 召唤成功时，限制双方玩家不能在当前连锁发动任何卡的效果
function c10000020.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 限制直到连锁结束为止，双方玩家不能发动卡的效果
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 检查这张卡是否是通过特殊召唤上场的
function c10000020.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤的结束阶段送去墓地效果的发动准备与操作信息设置
function c10000020.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置送去墓地的操作信息，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 特殊召唤的结束阶段送去墓地效果的执行，将自身送去墓地
function c10000020.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 计算自己手卡数量乘以1000的数值作为攻击力·守备力上升值
function c10000020.adval(e,c)
	-- 获取自己手卡数量，并返回乘上1000后的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end
-- 过滤对方场上以表侧攻击表示召唤·特殊召唤的怪兽
function c10000020.atkfilter(c,tp)
	return c:IsControler(tp) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 检查是否有对方怪兽以攻击表示召唤·特殊召唤，并将其设为效果目标
function c10000020.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c10000020.atkfilter,1,e:GetHandler(),1-tp) end
	local g=eg:Filter(c10000020.atkfilter,e:GetHandler(),1-tp)
	-- 将符合条件的攻击表示召唤·特殊召唤的怪兽设为当前连锁的目标对象
	Duel.SetTargetCard(g)
end
-- 执行让对方怪兽攻击力下降2000，且在攻击力降为0时将其破坏的操作
function c10000020.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中与效果相关且表侧表示的怪兽列表
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		local preatk=tc:GetAttack()
		-- 那些怪兽的攻击力下降2000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	-- 破坏攻击力降为0的怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end

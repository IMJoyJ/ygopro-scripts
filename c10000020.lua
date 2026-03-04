--オシリスの天空竜
-- 效果：
-- 这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
-- ③：这张卡的攻击力·守备力上升自己手卡数量×1000。
-- ④：每次对方场上有怪兽攻击表示召唤·特殊召唤发动。那些怪兽的攻击力下降2000。变成0的场合那怪兽破坏。
-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
function c10000020.initial_effect(c)
	-- ①：这张卡的召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000020,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000020.ttcon)
	e1:SetOperation(c10000020.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000020.setcon)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力·守备力上升自己手卡数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- ④：每次对方场上有怪兽攻击表示召唤·特殊召唤发动。那些怪兽的攻击力下降2000。变成0的场合那怪兽破坏。
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
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
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
	-- 把3只解放作召唤
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
-- 判断是否满足通常召唤需要3只祭品的条件
function c10000020.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查场上是否存在3只可用于通常召唤的祭品
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 特殊召唤时执行的祭品选择与解放操作
function c10000020.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3只祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的祭品解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断是否满足放置召唤的条件
function c10000020.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 召唤成功时执行的操作
function c10000020.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制，使双方在此连锁结束后无法发动卡的效果
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 判断是否满足结束阶段发动的条件
function c10000020.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置发动时的目标
function c10000020.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 发动效果时执行的操作
function c10000020.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 计算攻击力提升值
function c10000020.adval(e,c)
	-- 获取自己手卡数量并乘以1000作为攻击力提升值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end
-- 判断目标是否为攻击表示的怪兽
function c10000020.atkfilter(c,tp)
	return c:IsControler(tp) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 设置攻击表示召唤/特殊召唤时的触发效果目标
function c10000020.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c10000020.atkfilter,1,e:GetHandler(),1-tp) end
	local g=eg:Filter(c10000020.atkfilter,e:GetHandler(),1-tp)
	-- 设置连锁处理的目标怪兽
	Duel.SetTargetCard(g)
end
-- 执行攻击下降与破坏效果
function c10000020.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理中涉及的攻击表示怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		local preatk=tc:GetAttack()
		-- 为怪兽添加攻击力下降2000的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	-- 若怪兽攻击力变为0则将其破坏
	Duel.Destroy(dg,REASON_EFFECT)
end

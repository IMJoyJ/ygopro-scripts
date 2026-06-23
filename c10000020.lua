--オシリスの天空竜
-- 效果：
-- 这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
-- ③：这张卡的攻击力·守备力上升自己手卡数量×1000。
-- ④：每次对方场上有怪兽攻击表示召唤·特殊召唤发动。那些怪兽的攻击力下降2000。变成0的场合那怪兽破坏。
-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
function c10000020.initial_effect(c)
	-- 创建效果，描述为“把3只解放作召唤”，设置属性为不能无效和不可复制，类型为单次效果，代码为召唤限制过程，条件为c10000020.ttcon，操作为c10000020.ttop，值为上级召唤。相关子函数：c10000020.ttcon: 如果祭品数量小于等于3且存在祭品则返回true；c10000020.ttop: 从场上选择3只怪兽作为祭品，将它们设置为卡片素材并解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000020,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000020.ttcon)
	e1:SetOperation(c10000020.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 创建效果，类型为单次效果，代码为放置规则限制，条件为c10000020.setcon。相关子函数：c10000020.setcon: 如果卡片存在则返回false。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000020.setcon)
	c:RegisterEffect(e2)
	-- 创建效果，类型为单次效果，代码为不能无效召唤，设置属性为不能无效和不可复制。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 创建效果，类型为单次+连续效果，代码为通常召唤成功时，操作为c10000020.sumsuc。相关子函数：c10000020.sumsuc: 禁用连锁直到连锁结束。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000020.sumsuc)
	c:RegisterEffect(e4)
	-- 创建效果，描述为“送去墓地”，分类为送去墓地效果，类型为场地+诱发必发效果，作用范围为怪兽区，限制次数为1次，代码为阶段结束时，条件为c10000020.tgcon，目标为c10000020.tgtg，操作为c10000020.tgop。相关子函数：c10000020.tgcon: 如果这张卡是特殊召唤则返回true；c10000020.tgtg: 设置操作信息为送去墓地效果；c10000020.tgop: 如果这张卡与效果相关且表侧表示，则将它送去墓地。
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
	-- 创建效果，类型为单次效果，代码为增加攻击力，设置属性为只对自己有效，作用范围为怪兽区，值为c10000020.adval。相关子函数：c10000020.adval: 返回手牌数量乘以1000。
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
	-- 克隆e6效果，并将代码设置为增加守备力。
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
-- 创建效果，描述为“攻击下降”，分类为改变攻击效果，类型为场地+诱发必发效果，作用范围为怪兽区，代码为通常召唤成功时，目标为c10000020.atktg，操作为c10000020.atkop。
function c10000020.ttcon(e,c,minc)
	if c==nil then return true end
	-- 创建效果，克隆e8效果，并将代码设置为特殊召唤成功时。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 定义函数c10000020.ttcon，判断是否满足通常召唤条件。
function c10000020.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 检查祭品数量和场上是否存在足够的祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 定义函数c10000020.ttop，处理通常召唤的祭品选择和解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 从玩家场上选择3只怪兽作为祭品。
function c10000020.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 将选定的怪兽设置为卡片素材并解放。
function c10000020.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 定义函数c10000020.setcon，判断是否满足放置条件。
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 定义函数c10000020.sumsuc，禁用连锁直到连锁结束。
function c10000020.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 禁用连锁直到连锁结束。
function c10000020.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 定义函数c10000020.tgcon，判断是否为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 定义函数c10000020.tgtg，设置操作信息。
function c10000020.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置操作信息为送去墓地效果。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 定义函数c10000020.tgop，将卡片送去墓地。
function c10000020.adval(e,c)
	-- 将这张卡送去墓地。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end
-- 定义函数c10000020.adval，计算攻击力增益。
function c10000020.atkfilter(c,tp)
	return c:IsControler(tp) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 返回手牌数量乘以1000。
function c10000020.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c10000020.atkfilter,1,e:GetHandler(),1-tp) end
	local g=eg:Filter(c10000020.atkfilter,e:GetHandler(),1-tp)
	-- 定义函数c10000020.atkfilter，筛选表侧表示的对方怪兽。
	Duel.SetTargetCard(g)
end
-- 定义函数c10000020.atktg，设置攻击力改变的目标卡片。
function c10000020.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置目标卡片为符合atkfilter条件的怪兽组。
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		local preatk=tc:GetAttack()
		-- 创建单次效果，降低攻击力，并重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	-- 将受到的伤害的怪兽破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end

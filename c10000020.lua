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
-- 召唤条件判断：检查是否满足3只解放的要求，且场上有3个可用于召唤的祭品
function c10000020.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查玩家是否能提供3只解放作召唤
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 召唤操作的执行：选择3只祭品解放，并为该卡设置解放素材
function c10000020.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3只用于通常召唤该卡的解放怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选取的怪兽
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 放置条件限制：直接返回false，使得此卡不能被里侧表示放置
function c10000020.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 召唤成功时的处理：在召唤成功时设置连锁限制，阻止任何卡的效果发动
function c10000020.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁条件限制为不能发动效果
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 送去墓地效果的发动条件：判断此卡是否为特殊召唤
function c10000020.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 送去墓地效果的目标确定：设置操作信息为将该卡送去墓地
function c10000020.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果的操作信息为将自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 送去墓地效果的执行：如果此卡在场上表侧表示存在，则将其送去墓地
function c10000020.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 获取并返回要上升的数值：自己手卡数量×1000
function c10000020.adval(e,c)
	-- 计算并返回玩家手卡数量乘以1000的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end
-- 过滤条件：属于对方的且为表侧攻击表示的怪兽
function c10000020.atkfilter(c,tp)
	return c:IsControler(tp) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 召唤·特殊召唤时效果的目标确定：筛选出对方场上所有攻击表示召唤·特殊召唤的怪兽并将其设置为效果的目标卡
function c10000020.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c10000020.atkfilter,1,e:GetHandler(),1-tp) end
	local g=eg:Filter(c10000020.atkfilter,e:GetHandler(),1-tp)
	-- 设置效果的目标卡
	Duel.SetTargetCard(g)
end
-- 召唤·特殊召唤时效果的执行：使目标怪兽攻击力下降2000，并在其攻击力因此效果变成0时将其破坏
function c10000020.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出场上与该效果相关的表侧表示的目标怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		local preatk=tc:GetAttack()
		-- ④：每次对方场上有怪兽攻击表示召唤·特殊召唤发动。那些怪兽的攻击力下降2000。变成0的场合那怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	-- 破坏所有攻击力因此效果降低到0的怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end

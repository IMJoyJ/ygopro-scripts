--ハネクリボー LV9
-- 效果：
-- 当有连锁发生时，可以从自己手卡把这张卡特殊召唤。只要这张卡在自己场上表侧表示存在，双方发动的魔法卡不送去墓地从游戏中除外。这张卡的攻击力·守备力变成对方墓地存在的魔法卡数量×500的数值。「羽翼栗子球 LV9」在自己场上只能有1张表侧表示存在。
function c33776734.initial_effect(c)
	c:SetUniqueOnField(1,0,33776734)
	-- 当有连锁发生时，可以从自己手卡把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33776734,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,33776734+EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c33776734.spcon)
	e1:SetTarget(c33776734.sptg)
	e1:SetOperation(c33776734.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，双方发动的魔法卡不送去墓地从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c33776734.rmtarget)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力·守备力变成对方墓地存在的魔法卡数量×500的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c33776734.val)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e4)
	if not c33776734.global_check then
		c33776734.global_check=true
		-- 「羽翼栗子球 LV9」在自己场上只能有1张表侧表示存在。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c33776734.checkop1)
		-- 注册连锁发动时的处理效果。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(c33776734.checkop2)
		-- 注册连锁发动无效时的处理效果。
		Duel.RegisterEffect(ge2,0)
	end
end
c33776734.lvup={33776734}
c33776734.lvdn={48486809}
-- 记录当前发动的魔法卡，用于标记其为被羽翼栗子球 LV9影响的卡。
function c33776734.checkop1(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		re:GetHandler():RegisterFlagEffect(33776734,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 当魔法卡的连锁被无效时，清除其标记。
function c33776734.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		re:GetHandler():ResetFlagEffect(33776734)
	end
end
-- 判断当前连锁是否为第2个或之后的连锁。
function c33776734.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁序号大于等于2时满足条件。
	return Duel.GetCurrentChain()>=2
end
-- 设置特殊召唤的处理目标和条件。
function c33776734.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作。
function c33776734.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片以表侧表示形式特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断目标魔法卡是否为表侧表示且被标记。
function c33776734.rmtarget(e,c)
	return c:IsFaceup() and c:GetFlagEffect(33776734)>0
end
-- 计算对方墓地魔法卡数量并乘以500作为攻击力和守备力。
function c33776734.val(e,c)
	-- 获取对方墓地魔法卡的数量并乘以500
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),0,LOCATION_GRAVE,nil,TYPE_SPELL)*500
end

--ハネクリボー LV9
-- 效果：
-- 当有连锁发生时，可以从自己手卡把这张卡特殊召唤。只要这张卡在自己场上表侧表示存在，双方发动的魔法卡不送去墓地从游戏中除外。这张卡的攻击力·守备力变成对方墓地存在的魔法卡数量×500的数值。「羽翼栗子球 LV9」在自己场上只能有1张表侧表示存在。
function c33776734.initial_effect(c)
	c:SetUniqueOnField(1,0,33776734)
	-- 对应效果原文：“当有连锁发生时，可以从自己手卡把这张卡特殊召唤。”
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
	-- 对应效果原文：“只要这张卡在自己场上表侧表示存在，双方发动的魔法卡不送去墓地从游戏中除外。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c33776734.rmtarget)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- 对应效果原文：“这张卡的攻击力·守备力变成对方墓地存在的魔法卡数量×500的数值。”
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
		-- 对应效果原文：“当有连锁发生时，可以从自己手卡把这张卡特殊召唤。只要这张卡在自己场上表侧表示存在，双方发动的魔法卡不送去墓地从游戏中除外。这张卡的攻击力·守备力变成对方墓地存在的魔法卡数量×500的数值。「羽翼栗子球 LV9」在自己场上只能有1张表侧表示存在。”
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c33776734.checkop1)
		-- 将该全局效果注册给玩家0，用于在每次有连锁发生时监听魔法卡的发动并为其添加标记。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(c33776734.checkop2)
		-- 将该全局效果（ge1的克隆）注册给玩家0，用于在魔法卡发动被无效时清除其标记，保证被无效的魔法卡不算作“发动的魔法卡”。
		Duel.RegisterEffect(ge2,0)
	end
end
c33776734.lvup={33776734}
c33776734.lvdn={48486809}
-- 当连锁发生时，若发动的是魔法卡，则给该魔法卡附加33776734标记（持续到其离场/回手/回卡组等），以此识别“双方发动的魔法卡”。
function c33776734.checkop1(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		re:GetHandler():RegisterFlagEffect(33776734,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 当魔法卡发动被无效时，清除该魔法卡上的33776734标记，表示该魔法卡并未成功发动。
function c33776734.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		re:GetHandler():ResetFlagEffect(33776734)
	end
end
-- 特殊召唤效果的发动条件判断函数：当前连锁数≥2时满足“有连锁发生”的条件，允许从手卡特殊召唤。
function c33776734.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁数是否大于等于2，是则返回true，作为特殊召唤效果的发动条件。
	return Duel.GetCurrentChain()>=2
end
-- 特殊召唤效果发动时的目标检查：确认己方主要怪兽区有空位，且此卡可以特殊召唤。
function c33776734.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查怪兽区是否有空位，若没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本效果将把这张卡特殊召唤，数量为1，供系统进行发动合法性/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数：若此卡仍与效果关联，则将其特殊召唤上场。
function c33776734.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：由tp将这张卡以表侧表示特殊召唤到己方场上，不检查召唤条件/苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 除外替代效果的筛选函数：只有表侧表示且带有33776734标记的卡（即发动过且未被无效的魔法卡）才会被改为除外。
function c33776734.rmtarget(e,c)
	return c:IsFaceup() and c:GetFlagEffect(33776734)>0
end
-- 攻防数值计算函数：统计对方墓地中的魔法卡数量，供攻击力/守备力设定效果使用。
function c33776734.val(e,c)
	-- 返回对方墓地存在的魔法卡数量乘以500，作为这张卡的攻击力/守备力数值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),0,LOCATION_GRAVE,nil,TYPE_SPELL)*500
end

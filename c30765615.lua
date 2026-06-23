--百檎龍－リンゴブルム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有效果怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己把同调怪兽同调召唤的回合的自己主要阶段，把墓地的这张卡除外才能发动。在自己场上把1只「百檎衍生物」（幻龙族·光·2星·攻/守100）特殊召唤。自己把这衍生物作为同调素材的场合，可以当作调整使用。
function c30765615.initial_effect(c)
	-- ①：这张卡在手卡存在，场上有效果怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30765615)
	e1:SetCondition(c30765615.spcon)
	e1:SetTarget(c30765615.sptg)
	e1:SetOperation(c30765615.spop)
	c:RegisterEffect(e1)
	-- ②：自己把同调怪兽同调召唤的回合的自己主要阶段，把墓地的这张卡除外才能发动。在自己场上把1只「百檎衍生物」（幻龙族·光·2星·攻/守100）特殊召唤。自己把这衍生物作为同调素材的场合，可以当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30765616)
	e2:SetCondition(c30765615.tkcon)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30765615.tktg)
	e2:SetOperation(c30765615.tkop)
	c:RegisterEffect(e2)
	if not c30765615.global_check then
		c30765615.global_check=true
		-- 当有同调怪兽特殊召唤成功时，为该玩家注册一个标识效果，用于判断是否可以发动②效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c30765615.checkop)
		-- 将效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数，用于判断是否为同调召唤的怪兽
function c30765615.checkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 当有怪兽特殊召唤成功时，为该怪兽的控制者注册一个标识效果，用于判断是否可以发动②效果
function c30765615.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c30765615.checkfilter,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为玩家注册一个标识效果，用于判断是否可以发动②效果
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),30765615,RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
end
-- 过滤函数，用于判断是否为表侧表示的非效果怪兽
function c30765615.spcfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 判断场上是否存在表侧表示的非效果怪兽
function c30765615.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场上存在表侧表示的非效果怪兽
	return Duel.IsExistingMatchingCard(c30765615.spcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置特殊召唤的处理信息
function c30765615.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c30765615.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否可以发动②效果
function c30765615.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已注册过标识效果
	return Duel.GetFlagEffect(tp,30765615)>0
end
-- 设置特殊召唤衍生物的处理信息
function c30765615.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,30765616,0,TYPES_TOKEN_MONSTER,100,100,2,RACE_WYRM,ATTRIBUTE_LIGHT) end
	-- 设置衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行特殊召唤衍生物的操作
function c30765615.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断是否可以特殊召唤衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,30765616,0,TYPES_TOKEN_MONSTER,100,100,2,RACE_WYRM,ATTRIBUTE_LIGHT) then
		-- 创建一个百檎衍生物
		local token=Duel.CreateToken(tp,30765616)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 为衍生物设置可以当作调整使用的属性
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TUNER)
		e1:SetValue(c30765615.tnval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
-- 判断是否可以将衍生物当作调整使用
function c30765615.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end

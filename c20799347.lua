--電脳堺嫦－兎々
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有念动力族·幻龙族怪兽的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1只念动力族·幻龙族怪兽才能发动。这张卡当作调整使用特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c20799347.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有念动力族·幻龙族怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20799347,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c20799347.ntcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡丢弃1只念动力族·幻龙族怪兽才能发动。这张卡当作调整使用特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20799347,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20799347)
	e2:SetCost(c20799347.spcost)
	e2:SetTarget(c20799347.sptg)
	e2:SetOperation(c20799347.spop)
	c:RegisterEffect(e2)
end
c20799347.treat_itself_tuner=true
-- 过滤函数，用于判断场上是否存在非念动力族或非幻龙族的怪兽。
function c20799347.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_PSYCHO+RACE_WYRM)
end
-- 召唤条件函数，判断是否满足不用解放作召唤的条件。
function c20799347.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 满足召唤条件：召唤时不需要解放，等级大于等于5，且场上存在空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 满足召唤条件：场上没有怪兽或只有念动力族/幻龙族怪兽。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c20799347.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 丢弃费用过滤函数，用于筛选手牌中可丢弃的念动力族或幻龙族怪兽。
function c20799347.costfilter(c)
	return c:IsRace(RACE_PSYCHO+RACE_WYRM) and c:IsDiscardable()
end
-- 特殊召唤的丢弃费用处理函数，从手牌中丢弃1只符合条件的怪兽。
function c20799347.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃费用条件，即手牌中存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c20799347.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作，从手牌中丢弃1只符合条件的怪兽。
	Duel.DiscardHand(tp,c20799347.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤目标设定函数，判断是否可以将此卡特殊召唤。
function c20799347.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位，用于判断是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理函数，执行特殊召唤并附加调整属性和除外效果。
function c20799347.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤，若可以则执行特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将此卡添加调整属性，使其具有调整的种类。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		-- 设置此卡离场时被除外的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- 设置本回合不能特殊召唤等级或阶级低于3的怪兽的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c20799347.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册本回合不能特殊召唤等级或阶级低于3的怪兽的效果。
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的函数，判断怪兽是否等级或阶级低于3。
function c20799347.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end

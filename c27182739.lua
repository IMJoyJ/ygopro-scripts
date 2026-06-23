--斬機シグマ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，额外怪兽区域没有自己怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
-- ②：把自己场上的这张卡作为「斩机」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c27182739.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，额外怪兽区域没有自己怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,27182739)
	e1:SetCondition(c27182739.spcon)
	e1:SetTarget(c27182739.sptg)
	e1:SetOperation(c27182739.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上的这张卡作为「斩机」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(c27182739.tnval)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在额外怪兽区域的怪兽
function c27182739.cfilter(c)
	return c:GetSequence()>=5
end
-- 效果发动条件：额外怪兽区域没有自己怪兽存在
function c27182739.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 额外怪兽区域没有自己怪兽存在
	return not Duel.IsExistingMatchingCard(c27182739.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 准备阶段设置特殊召唤目标
function c27182739.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果，包括离场时除外和限制召唤效果
function c27182739.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤后将该卡离场时移至除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 发动后直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c27182739.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制召唤效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤效果的过滤函数：非电子界族怪兽不能从额外卡组特殊召唤
function c27182739.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
-- 同调素材使用效果的过滤函数：将自身当作非调整怪兽使用
function c27182739.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsSetCard(0x132)
end

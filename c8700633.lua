--不屈の獣僕
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方把3只以上的怪兽特殊召唤的回合的主要阶段才能发动。这张卡从手卡·墓地特殊召唤。这个效果在对方回合也能发动。
-- ②：自己场上没有其他怪兽存在的场合，攻击表示的这张卡不会被战斗破坏。
function c8700633.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方把3只以上的怪兽特殊召唤的回合的主要阶段才能发动。这张卡从手卡·墓地特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8700633,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,8700633)
	e1:SetCondition(c8700633.spcon)
	e1:SetTarget(c8700633.sptg)
	e1:SetOperation(c8700633.spop)
	c:RegisterEffect(e1)
	if not c8700633.global_check then
		c8700633.global_check=true
		-- ①：对方把3只以上的怪兽特殊召唤的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c8700633.checkop)
		-- 在全局环境注册用于记录特殊召唤怪兽次数的全局效果
		Duel.RegisterEffect(ge1,0)
	end
	-- ②：自己场上没有其他怪兽存在的场合，攻击表示的这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c8700633.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 特殊召唤成功时的操作函数，用于遍历并记录特殊召唤怪兽的玩家
function c8700633.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为特殊召唤怪兽的玩家注册一个持续到回合结束的标识效果，每召唤一只怪兽注册一个，用于计数
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),8700633,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 特殊召唤效果的发动条件函数
function c8700633.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方在本回合是否特殊召唤了3只以上的怪兽，且当前是否为主要阶段
	return Duel.GetFlagEffect(1-tp,8700633)>=3 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 特殊召唤效果的发动准备与检测函数
function c8700633.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，判断自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理函数
function c8700633.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 战斗不破效果的适用条件函数
function c8700633.indcon(e)
	-- 判断自己场上的怪兽数量是否在1只以下（即没有其他怪兽存在），且这张卡是否处于表侧攻击表示
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)<=1 and e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end

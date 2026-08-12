--エーリアン・スカル
-- 效果：
-- 可以把对方场上1只3星以下的怪兽解放，这张卡从手卡往对方场上特殊召唤。这个方法特殊召唤的场合，这个回合自己不能通常召唤，特殊召唤时给这张卡放置1个A指示物。只要这张卡在场上表侧表示存在，有A指示物放置的怪兽和名字带有「外星」的怪兽进行战斗的场合，只在伤害计算时A指示物每有1个攻击力·守备力下降300。
function c25920413.initial_effect(c)
	-- 可以把对方场上1只3星以下的怪兽解放，这张卡从手卡往对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP,1)
	e1:SetCondition(c25920413.spcon)
	e1:SetTarget(c25920413.sptg)
	e1:SetOperation(c25920413.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 特殊召唤时给这张卡放置1个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25920413,0))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c25920413.ctcon)
	e2:SetOperation(c25920413.ctop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，有A指示物放置的怪兽和名字带有「外星」的怪兽进行战斗的场合，只在伤害计算时A指示物每有1个攻击力·守备力下降300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c25920413.adcon)
	e3:SetTarget(c25920413.adtg)
	e3:SetValue(c25920413.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
c25920413.counter_add_list={0x100e}
c25920413.mentioned_counter={
	[0x100e]=true,
}
-- 解放对象过滤函数：筛选对方场上3星以下、表侧表示、可以因特殊召唤而解放，且解放后对方怪兽区有空位的怪兽
function c25920413.spfilter(c,tp)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsReleasable(REASON_SPSUMMON)
		-- 检查该卡解放后对方场上是否有可用的怪兽区域（用于把这张卡特殊召唤到对方场上）
		and Duel.GetMZoneCount(1-tp,c,tp)
end
-- 特殊召唤条件：本回合自己没有进行过通常召唤，且对方场上存在至少1只满足条件的可解放怪兽
function c25920413.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查本回合自己进行通常召唤的次数为0
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		-- 检查对方场上是否存在至少1只满足过滤条件的可解放怪兽
		and Duel.IsExistingMatchingCard(c25920413.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤的对象选择：从对方场上满足条件的怪兽中选择1只作为解放对象，选不到则不能特殊召唤
function c25920413.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足条件的可解放怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c25920413.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 向玩家发送「请选择要解放的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理：解放选中的对方怪兽，并对自己注册本回合不能召唤、不能覆盖放置的效果
function c25920413.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选中的对方怪兽
	Duel.Release(g,REASON_SPSUMMON)
	-- 这个方法特殊召唤的场合，这个回合自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 把「这个回合自己不能召唤」的效果作为玩家效果注册给自己
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 把「这个回合自己不能覆盖放置怪兽」的效果作为玩家效果注册给自己
	Duel.RegisterEffect(e2,tp)
end
-- 指示物效果的适用条件：确认这张卡是用自身方法（SUMMON_VALUE_SELF）特殊召唤成功的
function c25920413.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 指示物效果的处理：这张卡表侧表示存在的场合，给这张卡放置1个A指示物
function c25920413.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:AddCounter(0x100e,1)
	end
end
-- 攻击力·守备力变化的适用条件：仅在伤害计算时且存在攻击对象（即正在进行战斗）时适用
function c25920413.adcon(e)
	-- 判断当前阶段为伤害计算阶段且存在攻击对象
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 对象：放置有A指示物、且正在和名字带有「外星」的怪兽进行战斗的怪兽
function c25920413.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 攻击力·守备力下降的数值：该怪兽放置的A指示物数量每有1个下降300
function c25920413.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

--エーリアン・スカル
-- 效果：
-- 可以把对方场上1只3星以下的怪兽解放，这张卡从手卡往对方场上特殊召唤。这个方法特殊召唤的场合，这个回合自己不能通常召唤，特殊召唤时给这张卡放置1个A指示物。只要这张卡在场上表侧表示存在，有A指示物放置的怪兽和名字带有「外星」的怪兽进行战斗的场合，只在伤害计算时A指示物每有1个攻击力·守备力下降300。
function c25920413.initial_effect(c)
	-- 特殊召唤规则效果，允许从手牌解放对方场上1只3星以下的怪兽进行特殊召唤
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
	-- 特殊召唤成功时，给这张卡放置1个A指示物
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25920413,0))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c25920413.ctcon)
	e2:SetOperation(c25920413.ctop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，有A指示物放置的怪兽和名字带有「外星」的怪兽进行战斗的场合，只在伤害计算时A指示物每有1个攻击力·守备力下降300
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
-- 过滤函数，检查对方场上是否存在1只3星以下且可解放的怪兽
function c25920413.spfilter(c,tp)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsReleasable(REASON_SPSUMMON)
		-- 检查对方场上是否存在可用的怪兽区域
		and Duel.GetMZoneCount(1-tp,c,tp)
end
-- 检查该回合玩家是否未进行过通常召唤
function c25920413.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只满足条件的怪兽
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		-- 选择并解放对方场上1只3星以下的怪兽
		and Duel.IsExistingMatchingCard(c25920413.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 获取满足条件的对方怪兽组
function c25920413.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 提示玩家选择要解放的怪兽
	local g=Duel.GetMatchingGroup(c25920413.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 执行特殊召唤时的解放操作
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 将目标怪兽从手牌特殊召唤到对方场上
function c25920413.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	-- 禁止该回合玩家进行通常召唤和设置
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册禁止通常召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册禁止设置的效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断该怪兽是否为特殊召唤且为自身效果召唤
function c25920413.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 在特殊召唤成功时给该怪兽放置1个A指示物
function c25920413.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:AddCounter(0x100e,1)
	end
end
-- 判断当前是否为伤害计算阶段且存在攻击目标
function c25920413.adcon(e)
	-- 判断当前是否为伤害计算阶段且存在攻击目标
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 判断战斗中的怪兽是否满足条件（有A指示物且对方怪兽为外星族）
function c25920413.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算A指示物对攻击力/守备力的减益值
function c25920413.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

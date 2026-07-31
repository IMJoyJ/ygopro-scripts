--エーリアン・スカル
-- 效果：
-- 可以把对方场上1只3星以下的怪兽解放，这张卡从手卡往对方场上特殊召唤。这个方法特殊召唤的场合，这个回合自己不能通常召唤，特殊召唤时给这张卡放置1个A指示物。只要这张卡在场上表侧表示存在，有A指示物放置的怪兽和名字带有「外星」的怪兽进行战斗的场合，只在伤害计算时A指示物每有1个攻击力·守备力下降300。
function c25920413.initial_effect(c)
	-- 特殊召唤规则效果，允许从手卡将此卡特殊召唤至对方场上，条件为对方场上有3星以下的怪兽且自己本回合未通常召唤
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
	-- 特殊召唤成功时放置1个A指示物的效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25920413,0))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c25920413.ctcon)
	e2:SetOperation(c25920413.ctop)
	c:RegisterEffect(e2)
	-- 战斗阶段伤害计算时，有A指示物的怪兽与名字带有「外星」的怪兽战斗时，攻击力和守备力各下降300
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
-- 过滤函数，用于筛选对方场上3星以下且可被解放的怪兽
function c25920413.spfilter(c,tp)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsReleasable(REASON_SPSUMMON)
		-- 检查对方场上的怪兽区是否可用（排除目标怪兽离开后的情况）
		and Duel.GetMZoneCount(1-tp,c,tp)
end
-- 判断自己本回合是否未进行通常召唤
function c25920413.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在满足条件的怪兽
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		-- 选择并提示玩家解放一只3星以下的怪兽
		and Duel.IsExistingMatchingCard(c25920413.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 获取满足条件的怪兽数组并提示选择要解放的卡
function c25920413.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 提示玩家选择要解放的怪兽
	local g=Duel.GetMatchingGroup(c25920413.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 执行解放操作，将选中的怪兽从场上解放
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤成功后，禁止本回合通常召唤和设置召唤
function c25920413.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽解放以完成特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
	-- 注册不能通常召唤的效果，持续到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将不能通常召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 将不能设置召唤的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 判断此卡是否为特殊召唤（非通常召唤）成功
function c25920413.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 在特殊召唤成功时放置1个A指示物
function c25920413.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:AddCounter(0x100e,1)
	end
end
-- 判断当前阶段是否为伤害计算阶段且存在攻击目标
function c25920413.adcon(e)
	-- 检查当前阶段是否为伤害计算阶段且有攻击目标
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 判断战斗中的怪兽是否有A指示物且对方怪兽名字带有「外星」
function c25920413.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 根据A指示物数量计算攻击力和守备力下降值
function c25920413.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

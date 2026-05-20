--エーリアン・リベンジャー
-- 效果：
-- 这张卡可以把场上存在的2个A指示物取除，从手卡特殊召唤。1回合1次，可以给对方场上表侧表示存在的全部怪兽放置1个A指示物。有A指示物放置的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。「外星人复仇者」在自己场上只能有1只表侧表示存在。
function c63253763.initial_effect(c)
	c:SetUniqueOnField(1,0,63253763)
	-- 这张卡可以把场上存在的2个A指示物取除，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c63253763.spcon)
	e1:SetOperation(c63253763.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以给对方场上表侧表示存在的全部怪兽放置1个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63253763,0))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c63253763.cttg)
	e2:SetOperation(c63253763.ctop)
	c:RegisterEffect(e2)
	-- 有A指示物放置的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c63253763.adcon)
	e3:SetTarget(c63253763.adtg)
	e3:SetValue(c63253763.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
c63253763.counter_add_list={0x100e}
-- 特殊召唤规则的条件判断函数
function c63253763.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查场上（双方场上）是否能作为代价移去2个A指示物
		and Duel.IsCanRemoveCounter(c:GetControler(),1,1,0x100e,2,REASON_COST)
end
-- 特殊召唤规则的执行操作函数
function c63253763.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从场上（双方场上）移去2个A指示物作为特殊召唤的代价
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 放置A指示物效果的发动条件与目标检查函数
function c63253763.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认对方场上是否存在至少1只可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
end
-- 放置A指示物效果的执行处理函数
function c63253763.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以放置A指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x100e,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x100e,1)
		tc=g:GetNext()
	end
end
-- 攻击力·守备力下降效果的生效条件判断函数
function c63253763.adcon(e)
	-- 仅在伤害计算时且存在攻击对象（发生战斗）时生效
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 过滤受攻击力·守备力下降效果影响的怪兽（自身有A指示物且与「外星」怪兽战斗）
function c63253763.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算攻击力·守备力下降的数值（每个A指示物下降300）
function c63253763.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

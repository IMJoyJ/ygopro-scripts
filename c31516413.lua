--聖刻龍－ネフテドラゴン
-- 效果：
-- 这张卡可以把自己场上1只名字带有「圣刻」的怪兽解放从手卡特殊召唤。1回合1次，可以把这张卡以外的自己的手卡·场上1只名字带有「圣刻」的怪兽解放，选择对方场上1只怪兽破坏。此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
function c31516413.initial_effect(c)
	-- 这张卡可以把自己场上1只名字带有「圣刻」的怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c31516413.hspcon)
	e1:SetTarget(c31516413.hsptg)
	e1:SetOperation(c31516413.hspop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把这张卡以外的自己的手卡·场上1只名字带有「圣刻」的怪兽解放，选择对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31516413,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c31516413.descost)
	e2:SetTarget(c31516413.destg)
	e2:SetOperation(c31516413.desop)
	c:RegisterEffect(e2)
	-- 此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31516413,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(c31516413.sptg)
	e3:SetOperation(c31516413.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否满足特殊召唤条件的「圣刻」怪兽
function c31516413.hspfilter(c,tp)
	return c:IsSetCard(0x69)
		-- 判断目标怪兽是否在场上且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足特殊召唤的条件，即场上有可解放的「圣刻」怪兽
function c31516413.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c31516413.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择并设置要解放的「圣刻」怪兽
function c31516413.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的「圣刻」怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c31516413.hspfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作
function c31516413.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤原因解放目标怪兽
	Duel.Release(g,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31516413,2))  --"出场方式为特殊召唤"
end
-- 支付破坏效果的解放费用
function c31516413.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付破坏效果费用的条件
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,Card.IsSetCard,1,REASON_COST,true,e:GetHandler(),0x69) end
	-- 选择并释放满足条件的「圣刻」怪兽
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsSetCard,1,1,REASON_COST,true,e:GetHandler(),0x69)
	-- 以支付费用原因解放目标怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置破坏效果的目标
function c31516413.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否存在可破坏的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c31516413.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选龙族通常怪兽
function c31516413.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的操作信息
function c31516413.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 执行特殊召唤效果
function c31516413.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的怪兽区进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的龙族通常怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31516413.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试特殊召唤目标怪兽
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将目标怪兽的攻击力设置为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end

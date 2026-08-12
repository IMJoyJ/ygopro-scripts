--聖刻龍－シユウドラゴン
-- 效果：
-- ①：这张卡可以把自己场上1只「圣刻」怪兽解放从手卡特殊召唤。
-- ②：1回合1次，把这张卡以外的自己的手卡·场上1只「圣刻」怪兽解放，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。
-- ③：这张卡被解放的场合发动。从自己的手卡·卡组·墓地选1只龙族通常怪兽，攻击力·守备力变成0特殊召唤。
function c3300267.initial_effect(c)
	-- ①：这张卡可以把自己场上1只「圣刻」怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c3300267.hspcon)
	e1:SetTarget(c3300267.hsptg)
	e1:SetOperation(c3300267.hspop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡以外的自己的手卡·场上1只「圣刻」怪兽解放，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3300267,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c3300267.descost)
	e2:SetTarget(c3300267.destg)
	e2:SetOperation(c3300267.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合发动。从自己的手卡·卡组·墓地选1只龙族通常怪兽，攻击力·守备力变成0特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3300267,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(c3300267.sptg)
	e3:SetOperation(c3300267.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足「圣刻」字段、且有可用怪兽区的自己场上的怪兽
function c3300267.hspfilter(c,tp)
	return c:IsSetCard(0x69)
		-- 确保该怪兽有可用的怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否存在满足条件的怪兽用于特殊召唤
function c3300267.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足条件的怪兽用于特殊召唤
	return Duel.CheckReleaseGroupEx(tp,c3300267.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择并设置要解放的「圣刻」怪兽
function c3300267.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的可解放怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c3300267.hspfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作
function c3300267.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(3300267,2))  --"出场方式为特殊召唤"
end
-- 支付效果的解放费用
function c3300267.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,Card.IsSetCard,1,REASON_COST,true,e:GetHandler(),0x69) end
	-- 选择满足条件的解放怪兽
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsSetCard,1,1,REASON_COST,true,e:GetHandler(),0x69)
	-- 将指定怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤魔法·陷阱卡
function c3300267.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置破坏效果的目标
function c3300267.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c3300267.desfilter(chkc) end
	-- 检查是否存在可破坏的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c3300267.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c3300267.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c3300267.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤龙族通常怪兽
function c3300267.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的操作信息
function c3300267.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 执行特殊召唤效果
function c3300267.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的龙族通常怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3300267.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试特殊召唤选定的怪兽
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将选定怪兽的攻击力设为0
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

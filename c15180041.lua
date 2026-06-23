--沈黙の剣士－サイレント・ソードマン
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只战士族怪兽解放的场合才能特殊召唤。
-- ①：自己·对方的准备阶段发动。这张卡的攻击力上升500。
-- ②：1回合1次，魔法卡发动时才能发动。那个发动无效。
-- ③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默剑士」以外的1只「沉默剑士」怪兽无视召唤条件特殊召唤。
function c15180041.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只战士族怪兽解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只战士族怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c15180041.spcon)
	e2:SetTarget(c15180041.sptg)
	e2:SetOperation(c15180041.spop)
	c:RegisterEffect(e2)
	-- 自己·对方的准备阶段发动。这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15180041,0))
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetOperation(c15180041.atkop)
	c:RegisterEffect(e3)
	-- 1回合1次，魔法卡发动时才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15180041,1))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c15180041.condition)
	e4:SetTarget(c15180041.target)
	e4:SetOperation(c15180041.operation)
	c:RegisterEffect(e4)
	-- 场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默剑士」以外的1只「沉默剑士」怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(15180041,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c15180041.spcon2)
	e5:SetTarget(c15180041.sptg2)
	e5:SetOperation(c15180041.spop2)
	c:RegisterEffect(e5)
end
-- 筛选满足条件的战士族怪兽，包括其在场上的怪兽区数量大于0且为己方控制或表侧表示。
function c15180041.spfilter(c,tp)
	return c:IsRace(RACE_WARRIOR)
		-- 检查该怪兽是否在己方场上且其所在区域有空位。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查玩家场上是否存在满足spfilter条件的怪兽用于解放。
function c15180041.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足spfilter条件的怪兽用于解放。
	return Duel.CheckReleaseGroupEx(tp,c15180041.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 获取玩家可解放的怪兽组并筛选出满足spfilter条件的怪兽。
function c15180041.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组并筛选出满足spfilter条件的怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c15180041.spfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 将指定的怪兽进行解放。
function c15180041.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽进行解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 使该卡在准备阶段时攻击力上升500。
function c15180041.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使该卡攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否为魔法卡发动且可被无效。
function c15180041.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 判断连锁是否可被无效且该卡未在战斗中被破坏。
		and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置操作信息为使发动无效。
function c15180041.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 使连锁发动无效。
function c15180041.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效。
	Duel.NegateActivation(ev)
end
-- 判断该卡是否因战斗或对方效果被破坏。
function c15180041.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选满足条件的沉默剑士怪兽，包括其类型、种族、不可为自身且可特殊召唤。
function c15180041.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe7) and not c:IsCode(15180041)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断是否满足特殊召唤条件，包括场上空位和手卡/卡组中存在符合条件的怪兽。
function c15180041.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡/卡组中是否存在符合条件的沉默剑士怪兽。
		and Duel.IsExistingMatchingCard(c15180041.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤操作。
function c15180041.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的沉默剑士怪兽。
	local g=Duel.SelectMatchingCard(tp,c15180041.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

--沈黙の魔術師－サイレント・マジシャン
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只魔法师族怪兽解放的场合才能特殊召唤。
-- ①：这张卡的攻击力上升自己手卡数量×500。
-- ②：1回合1次，魔法卡发动时才能发动。那个发动无效。
-- ③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默魔术师」以外的1只「沉默魔术师」怪兽无视召唤条件特殊召唤。
function c41175645.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤。把自己场上1只魔法师族怪兽解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡不能通常召唤。把自己场上1只魔法师族怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c41175645.spcon)
	e2:SetTarget(c41175645.sptg)
	e2:SetOperation(c41175645.spop)
	c:RegisterEffect(e2)
	-- 效果原文：①：这张卡的攻击力上升自己手卡数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c41175645.value)
	c:RegisterEffect(e3)
	-- 效果原文：②：1回合1次，魔法卡发动时才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41175645,0))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c41175645.condition)
	e4:SetTarget(c41175645.target)
	e4:SetOperation(c41175645.operation)
	c:RegisterEffect(e4)
	-- 效果原文：③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默魔术师」以外的1只「沉默魔术师」怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(41175645,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c41175645.spcon2)
	e5:SetTarget(c41175645.sptg2)
	e5:SetOperation(c41175645.spop2)
	c:RegisterEffect(e5)
end
-- 检查目标怪兽是否为魔法师族且满足解放条件
function c41175645.spfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER)
		-- 检查目标怪兽是否在场上或自己控制下且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否存在满足条件的可解放怪兽
function c41175645.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c41175645.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择并设置要解放的怪兽
function c41175645.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c41175645.spfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行怪兽解放操作
function c41175645.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 执行怪兽解放操作
	Duel.Release(g,REASON_SPSUMMON)
end
-- 计算并设置攻击力
function c41175645.value(e,c)
	-- 计算手卡数量乘以500作为攻击力提升值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*500
end
-- 判断是否为魔法卡发动且可无效
function c41175645.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 判断连锁是否可无效且此卡未在战斗中破坏
		and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置操作信息为无效发动
function c41175645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行无效发动操作
function c41175645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效发动操作
	Duel.NegateActivation(ev)
end
-- 判断此卡是否因战斗或对方效果被破坏
function c41175645.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选可特殊召唤的沉默魔术师怪兽
function c41175645.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe8) and not c:IsCode(41175645)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断是否满足特殊召唤条件
function c41175645.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有可用怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组是否存在满足条件的沉默魔术师怪兽
		and Duel.IsExistingMatchingCard(c41175645.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤操作
function c41175645.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的沉默魔术师怪兽
	local g=Duel.SelectMatchingCard(tp,c41175645.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

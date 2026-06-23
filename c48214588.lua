--新風の空牙団
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用「空牙团」怪兽不能攻击宣言。
-- ①：把自己场上1只怪兽解放才能发动。比那只怪兽等级高1星或低1星的1只「空牙团」怪兽从手卡·卡组特殊召唤。
function c48214588.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用「空牙团」怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCountLimit(1,48214588+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c48214588.cost)
	e1:SetTarget(c48214588.target)
	e1:SetOperation(c48214588.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在1回合内是否进行过攻击宣言
	Duel.AddCustomActivityCounter(48214588,ACTIVITY_ATTACK,c48214588.counterfilter)
end
-- 过滤函数，判断卡片是否为「空牙团」种族
function c48214588.counterfilter(c)
	return c:IsSetCard(0x114)
end
-- 发动时检查是否在本回合内已经进行过攻击宣言，若未进行则设置效果无法发动
function c48214588.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查当前玩家在本回合是否已经进行过攻击宣言
	if chk==0 then return Duel.GetCustomActivityCount(48214588,tp,ACTIVITY_ATTACK)==0 end
	-- 创建一个影响全场怪兽区域的永续效果，使非「空牙团」怪兽不能攻击宣言
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c48214588.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 目标过滤函数，判断目标怪兽是否不是「空牙团」种族
function c48214588.atktg(e,c)
	return not c:IsSetCard(0x114)
end
-- 解放怪兽的过滤条件函数，检查场上是否存在满足条件的可解放怪兽
function c48214588.cfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 检查目标怪兽是否为己方控制或表侧表示，并且有可用的怪兽区域
	return lv>0 and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
		-- 检查在手卡和卡组中是否存在满足特殊召唤条件的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(c48214588.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 特殊召唤怪兽的过滤条件函数，判断目标怪兽等级是否为解放怪兽等级±1，并且是「空牙团」种族
function c48214588.spfilter(c,lv,e,tp)
	return c:IsLevel(lv+1,lv-1) and c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时检查是否有满足条件的可解放怪兽，若有则选择并解放该怪兽
function c48214588.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足解放条件的怪兽
		return Duel.CheckReleaseGroup(tp,c48214588.cfilter,1,nil,e,tp)
	end
	-- 从场上选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c48214588.cfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选中的怪兽进行解放作为发动代价
	Duel.Release(g,REASON_COST)
	-- 设置连锁操作信息，表示本次效果将特殊召唤「空牙团」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 发动效果时检查是否有足够的怪兽区域，并选择满足条件的「空牙团」怪兽进行特殊召唤
function c48214588.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家场上是否还有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡和卡组中选择满足等级条件的1只「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c48214588.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

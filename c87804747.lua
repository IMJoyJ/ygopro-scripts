--完全態・グレート・インセクト
-- 效果：
-- 昆虫族·8星怪兽＋昆虫族·7星怪兽
-- 自己对「完全态大昆虫」1回合只能有1次特殊召唤。这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把有装备卡装备的1只自己的守备力2000以上的昆虫族怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡不会被战斗破坏。
-- ②：场地区域有表侧表示卡存在的场合，自己·对方的战斗阶段才能发动1次。对方场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括召唤限制、融合素材、特殊召唤规则、战破抗性以及战斗阶段破坏对方怪兽的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	-- 设定融合召唤素材为满足s.mfilter1和s.mfilter2条件的怪兽各1只。
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ●把有装备卡装备的1只自己的守备力2000以上的昆虫族怪兽解放的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	-- ①：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：场地区域有表侧表示卡存在的场合，自己·对方的战斗阶段才能发动1次。对方场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_BATTLE_START)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件1：等级8的昆虫族怪兽。
function s.mfilter1(c)
	return c:IsLevel(8) and c:IsRace(RACE_INSECT)
end
-- 融合素材过滤条件2：等级7的昆虫族怪兽。
function s.mfilter2(c)
	return c:IsLevel(7) and c:IsRace(RACE_INSECT)
end
-- 特殊召唤限制判定函数，若从额外卡组特殊召唤，则必须是融合召唤（或符合其特召规则）。
function s.splimit(e,se,sp,st)
	-- 如果不是从额外卡组特殊召唤，或者满足融合召唤的限制，则可以特殊召唤。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 自身特召规则的解放怪兽过滤条件：自己场上的守备力2000以上、有装备卡装备的昆虫族怪兽，且解放后能腾出额外怪兽区域的空格。
function s.hspfilter(c,tp,sc)
	return c:IsRace(RACE_INSECT) and c:IsDefenseAbove(2000) and c:GetEquipCount()>0 and c:IsControler(tp)
		-- 检查解放该怪兽后是否有足够的额外卡组怪兽出场空格，且该怪兽可以作为特殊召唤的素材。
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 自身特召规则的条件判定函数，检查自己场上是否存在可解放的满足条件的怪兽。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足s.hspfilter过滤条件的可解放怪兽。
	return Duel.CheckReleaseGroupEx(tp,s.hspfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 自身特召规则的目标选择函数，让玩家选择1只满足条件的怪兽作为解放对象。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的怪兽组，并过滤出满足s.hspfilter条件的怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.hspfilter,nil,tp,c)
	-- 给玩家发送提示信息，提示选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 自身特召规则的执行函数，将选中的怪兽作为素材并解放。
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 将选中的怪兽因特殊召唤而解放。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 破坏效果的发动条件判定函数，必须在双方的战斗阶段，且场地区域有表侧表示的卡存在。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为战斗阶段（从战斗阶段开始到战斗阶段结束）。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 判定双方的场地区域是否存在至少1张表侧表示的卡。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 破坏效果的目标判定与操作信息注册函数。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上怪兽区的所有怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return #g>0 end
	-- 设置连锁的操作信息，表示该效果将破坏对方场上的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的执行函数，将对方场上的怪兽全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上怪兽区的所有怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 因效果破坏获取到的对方怪兽组。
	Duel.Destroy(g,REASON_EFFECT)
end

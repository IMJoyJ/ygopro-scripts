--超雷龍－サンダー・ドラゴン
-- 效果：
-- 「雷龙」＋雷族怪兽
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●雷族怪兽的效果在手卡发动的回合，把融合怪兽以外的自己场上1只雷族效果怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方不能用抽卡以外的方法从卡组把卡加入手卡。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1只雷族怪兽除外。
function c15291624.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为31786629的怪兽和1个雷族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,31786629,aux.FilterBoolFunction(Card.IsRace,RACE_THUNDER),1,true,true)
	-- ●雷族怪兽的效果在手卡发动的回合，把融合怪兽以外的自己场上1只雷族效果怪兽解放的场合可以从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡特殊召唤的条件为必须通过融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- local e2=Effect.CreateEffect(c) e2:SetType(EFFECT_TYPE_FIELD) e2:SetCode(EFFECT_SPSUMMON_PROC) e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE) e2:SetRange(LOCATION_EXTRA) e2:SetCondition(c15291624.spcon) e2:SetTarget(c15291624.sptg) e2:SetOperation(c15291624.spop) c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c15291624.spcon)
	e2:SetTarget(c15291624.sptg)
	e2:SetOperation(c15291624.spop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，对方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	-- 设置效果目标为对方玩家，禁止对方将卡从卡组加入手牌
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e3)
	-- local e4=Effect.CreateEffect(c) e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE) e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE) e4:SetRange(LOCATION_MZONE) e4:SetCode(EFFECT_DESTROY_REPLACE) e4:SetTarget(c15291624.reptg) c:RegisterEffect(e4)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c15291624.reptg)
	c:RegisterEffect(e4)
	-- 设置计数器，用于记录连锁次数，以判断是否满足特殊召唤条件
	Duel.AddCustomActivityCounter(15291624,ACTIVITY_CHAIN,c15291624.chainfilter)
end
-- 过滤函数，用于判断连锁是否由雷族怪兽从手卡发动
function c15291624.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsRace(RACE_THUNDER) and re:IsActiveType(TYPE_MONSTER)
		-- 判断连锁是否由雷族怪兽从手卡发动
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND)
end
-- 特殊召唤所需满足的条件过滤函数，检查是否为雷族效果怪兽且可作为融合素材
function c15291624.spfilter(c,fc,tp)
	return c:IsRace(RACE_THUNDER) and c:IsFusionType(TYPE_EFFECT) and not c:IsFusionType(TYPE_FUSION)
		-- 检查场上是否有足够的额外卡组召唤空位且该怪兽可作为融合素材
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0 and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤条件函数，检查是否满足连锁次数和解放条件
function c15291624.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家或对手是否有连锁发生
	return (Duel.GetCustomActivityCount(15291624,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(15291624,1-tp,ACTIVITY_CHAIN)~=0)
		-- 检查场上是否存在满足条件的可解放怪兽
		and Duel.CheckReleaseGroupEx(tp,c15291624.spfilter,1,REASON_SPSUMMON,false,nil,c,tp)
end
-- 特殊召唤目标函数，选择满足条件的怪兽进行解放
function c15291624.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的可解放怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c15291624.spfilter,nil,c,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作函数，设置融合素材并解放怪兽
function c15291624.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 执行解放操作
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 破坏代替效果的过滤函数，检查墓地是否有雷族怪兽可除外
function c15291624.repfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemove()
end
-- 破坏代替效果的目标函数，判断是否满足代替破坏条件
function c15291624.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查墓地是否存在满足条件的雷族怪兽
		and Duel.IsExistingMatchingCard(c15291624.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动破坏代替效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要除外的雷族怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的雷族怪兽进行除外
		local g=Duel.SelectMatchingCard(tp,c15291624.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 执行除外操作
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end

--神・スライム
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 水族怪兽＋水属性·10星怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只攻击力0的水族·10星怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：需要怪兽3只解放的怪兽上级召唤的场合，这张卡可以作为3只的数量解放。
-- ②：这张卡不会被战斗破坏，对方不能选择「神·史莱姆」以外的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
function c42166000.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的水族怪兽和神·史莱姆作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),c42166000.ffilter,true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c42166000.splimit)
	c:RegisterEffect(e1)
	-- ●把自己场上1只攻击力0的水族·10星怪兽解放的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c42166000.hspcon)
	e2:SetTarget(c42166000.hsptg)
	e2:SetOperation(c42166000.hspop)
	c:RegisterEffect(e2)
	-- ①：需要怪兽3只解放的怪兽上级召唤的场合，这张卡可以作为3只的数量解放。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(42166000)
	c:RegisterEffect(e0)
	-- ②：这张卡不会被战斗破坏，对方不能选择「神·史莱姆」以外的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42166000,0))  --"使用「神·史莱姆」作为3只的数量解放来召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCondition(c42166000.ttcon)
	e3:SetTarget(c42166000.RequireSummon)
	e3:SetOperation(c42166000.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	e4:SetTarget(c42166000.RequireSet)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_SUMMON_PROC)
	e5:SetTarget(c42166000.CanSummon)
	e5:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e5)
	local ea=e3:Clone()
	ea:SetCode(EFFECT_SUMMON_PROC)
	-- 设置效果目标为卡号为5008836的卡片
	ea:SetTarget(aux.TargetBoolFunction(Card.IsCode,5008836))
	ea:SetCondition(c42166000.t5con)
	ea:SetOperation(c42166000.t5op)
	ea:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(ea)
	-- 使这张卡不会被战斗破坏
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	-- 对方不能选择「神·史莱姆」以外的自己场上的怪兽作为攻击对象
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c42166000.tgtg)
	-- 设置效果值为过滤函数aux.tgoval
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- 对方不能选择「神·史莱姆」以外的自己场上的怪兽作为效果的对象
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e9:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetTargetRange(0,LOCATION_MZONE)
	e9:SetValue(c42166000.tgtg)
	c:RegisterEffect(e9)
end
-- 过滤函数，用于筛选融合属性为水且等级为10的怪兽
function c42166000.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_WATER) and c:IsLevel(10)
end
-- 设置特殊召唤条件，限制只能通过融合召唤特殊召唤
function c42166000.splimit(e,se,sp,st)
	-- 若此卡不在额外卡组则不生效，否则调用aux.fuslimit函数限制召唤方式
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 过滤函数，用于筛选攻击力为0、种族为水族、等级为10且满足召唤条件的怪兽
function c42166000.hspfilter(c,tp,sc)
	return c:IsAttack(0) and c:IsRace(RACE_AQUA) and c:IsLevel(10)
		-- 确保怪兽在场上、有足够召唤空间且可作为融合素材
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 设置特殊召唤条件，检查是否存在满足条件的怪兽可解放
function c42166000.hspcon(e,c)
	if c==nil then return true end
	-- 调用CheckReleaseGroupEx函数检查是否存在满足条件的怪兽
	return Duel.CheckReleaseGroupEx(c:GetControler(),c42166000.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 设置特殊召唤目标，选择满足条件的怪兽进行解放
function c42166000.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c42166000.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤操作，执行怪兽解放
function c42166000.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 执行解放操作，将指定怪兽从场上解放
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 过滤函数，用于筛选拥有神·史莱姆效果且可解放的怪兽
function c42166000.ttfilter(c,tp)
	-- 检查怪兽是否拥有神·史莱姆效果、可解放且场上存在召唤空间
	return c:IsHasEffect(42166000) and c:IsReleasable(REASON_SUMMON) and Duel.GetMZoneCount(tp,c)>0
end
-- 设置上级召唤条件，检查是否存在满足条件的怪兽
function c42166000.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的怪兽
	return minc<=3 and Duel.IsExistingMatchingCard(c42166000.ttfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 设置上级召唤目标，指定可作为上级召唤祭品的卡号
function c42166000.RequireSummon(e,c)
	return c:IsCode(10000000,10000010,10000020,10000080,21208154,57793869,62180201,57761191)
end
-- 设置放置召唤目标，指定可作为放置召唤祭品的卡号
function c42166000.RequireSet(e,c)
	return c:IsCode(21208154,57793869,62180201)
end
-- 设置召唤目标，指定可作为召唤祭品的卡号
function c42166000.CanSummon(e,c)
	return c:IsCode(3912064,25524823,36354007,75285069,78651105)
end
-- 设置上级召唤操作，选择满足条件的怪兽进行解放
function c42166000.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectMatchingCard(tp,c42166000.ttfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	c:SetMaterial(g)
	-- 执行解放操作，将指定怪兽从场上解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数，用于筛选非神·史莱姆的场上怪兽
function c42166000.tgtg(e,c)
	return not (c:IsCode(42166000) and c:IsFaceup())
end
-- 辅助函数，用于检查怪兽组是否满足条件并可作为祭品
function c42166000.gchk(g,tc,tp)
	-- 检查怪兽组是否满足条件并可作为祭品
	return g:IsExists(c42166000.ttfilter,1,nil,tp) and Duel.CheckTribute(tc,#g,#g,g)
end
-- 设置上级召唤条件，检查是否存在满足条件的怪兽组
function c42166000.t5con(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return minc<=5 and g:CheckSubGroup(c42166000.gchk,3,3,c,tp)
end
-- 设置上级召唤操作，选择满足条件的怪兽进行解放
function c42166000.t5op(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectTribute(tp,c,2,2)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽进行解放
	local sg=Duel.SelectMatchingCard(tp,c42166000.ttfilter,tp,LOCATION_MZONE,0,1,1,g,tp)
	g:Merge(sg)
	c:SetMaterial(g)
	-- 执行解放操作，将指定怪兽从场上解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

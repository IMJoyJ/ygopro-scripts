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
	-- 为这张卡添加融合召唤手续：可以以1只水族怪兽和1只水属性·10星怪兽作为融合素材进行融合召唤。
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
	-- 这张卡可以作为3只的数量解放。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(42166000)
	c:RegisterEffect(e0)
	-- ①：需要怪兽3只解放的怪兽上级召唤的场合，这张卡可以作为3只的数量解放。
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
	-- 设定该召唤规则仅适用于卡号5008836的怪兽（该怪兽上级召唤时也能使用「神·史莱姆」作为解放代用）。
	ea:SetTarget(aux.TargetBoolFunction(Card.IsCode,5008836))
	ea:SetCondition(c42166000.t5con)
	ea:SetOperation(c42166000.t5op)
	ea:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(ea)
	-- 这张卡不会被战斗破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	-- 对方不能选择「神·史莱姆」以外的自己场上的怪兽作为效果的对象。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c42166000.tgtg)
	-- 设置“不能成为效果的对象”的应用方式为aux.tgoval，即只有对方发动的效果不能选择己方受保护怪兽作为对象。
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- 对方不能选择「神·史莱姆」以外的自己场上的怪兽作为攻击对象。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e9:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetTargetRange(0,LOCATION_MZONE)
	e9:SetValue(c42166000.tgtg)
	c:RegisterEffect(e9)
end
-- 融合素材的过滤条件：该怪兽需为水属性且等级为10。
function c42166000.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_WATER) and c:IsLevel(10)
end
-- 特殊召唤限制函数：若这张卡在额外卡组，则仅允许融合召唤方式特殊召唤；不在额外卡组时不受此限制。
function c42166000.splimit(e,se,sp,st)
	-- 具体判定条件：当前不在额外卡组时返回true；若在额外卡组，则仅当特殊召唤类型为融合召唤（SUMMON_TYPE_FUSION）时返回true。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 特殊召唤手续的解放素材过滤：攻击力0、水族、10星、控制者为自己的怪兽，并且解放后额外卡组有空格可以特殊召唤这张卡，同时该怪兽可作为融合素材。
function c42166000.hspfilter(c,tp,sc)
	return c:IsAttack(0) and c:IsRace(RACE_AQUA) and c:IsLevel(10)
		-- 追加条件：该怪兽必须在自己场上，且将其解放后额外卡组仍有空位用于特殊召唤，并且该怪兽可以作为这张卡的融合素材。
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 该特殊召唤手续的条件：当尝试从额外卡组特殊召唤这张卡时，检查自己场上是否有满足hspfilter条件的可解放怪兽。
function c42166000.hspcon(e,c)
	if c==nil then return true end
	-- 具体检查：自己场上或手卡（非上级召唤用解放组）中是否存在至少1只满足hspfilter条件的可解放怪兽（含额外卡组特殊召唤空位检查）。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c42166000.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 特殊召唤手续的目标选择：从可解放怪兽中选择1只作为解放素材，成功则把该怪兽保存到效果标签并返回true。
function c42166000.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放（特殊召唤用）的怪兽中满足hspfilter条件的怪兽组，供玩家选择解放对象。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c42166000.hspfilter,nil,tp,c)
	-- 弹出“请选择要解放的卡”的提示消息，引导玩家选择解放怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作：将选择的怪兽记录为融合素材，并解放它，完成从额外卡组的特殊召唤。
function c42166000.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 解放被选择的怪兽，作为该特殊召唤手续的代价。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 可作为代替解放的怪兽过滤：必须是拥有42166000标记（即「神·史莱姆」）且可以作为上级召唤解放，并在解放后自己场上仍有空格。这里指这张卡本身。
function c42166000.ttfilter(c,tp)
	-- 判断条件：该卡拥有「神·史莱姆」标记（c:IsHasEffect(42166000)）、可以作为上级召唤的解放材料，且解放后自己怪兽区仍有空格。
	return c:IsHasEffect(42166000) and c:IsReleasable(REASON_SUMMON) and Duel.GetMZoneCount(tp,c)>0
end
-- 代替解放规则的条件：当上级召唤所需解放数不超过3，并且自己场上存在至少1只可用的「神·史莱姆」作为解放代用时，该规则适用。
function c42166000.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 具体判定为：minc<=3且自己场上存在满足ttfilter的「神·史莱姆」。
	return minc<=3 and Duel.IsExistingMatchingCard(c42166000.ttfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 指定需要3只解放的怪兽范围：包括巨神兵、翼神龙、天空龙、球体形、邪神神之化身、邪神抹灭者、邪神恐惧之源、真龙机兵十二炼机圣，这些怪兽上级召唤时适用「作为3只数量解放」的规则。
function c42166000.RequireSummon(e,c)
	return c:IsCode(10000000,10000010,10000020,10000080,21208154,57793869,62180201,57761191)
end
-- 指定需要3只解放且可以里侧守备表示上级召唤（放置）的怪兽范围：邪神神之化身、邪神抹灭者、邪神恐惧之源。
function c42166000.RequireSet(e,c)
	return c:IsCode(21208154,57793869,62180201)
end
-- 指定可以表侧上级召唤的、需要3只解放的怪兽范围：轻盈水星、守墓的审神者、闪电战士吉尔福德、莫伊斯彻星人、神兽王巴巴罗斯。
function c42166000.CanSummon(e,c)
	return c:IsCode(3912064,25524823,36354007,75285069,78651105)
end
-- 代替解放的操作：选择1只「神·史莱姆」作为解放素材，将其解放并作为上级召唤所需3只解放的代用。
function c42166000.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 弹出“请选择要解放的卡”的提示消息，引导玩家选择作为解放代用的「神·史莱姆」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只满足ttfilter条件的「神·史莱姆」作为解放素材。
	local g=Duel.SelectMatchingCard(tp,c42166000.ttfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	c:SetMaterial(g)
	-- 将选择的「神·史莱姆」解放，视为满足该上级召唤所需的3只解放数量。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 目标判定函数：当目标是表侧表示的「神·史莱姆」时返回false（不保护，可被选为对象/攻击目标）；其他情况下返回true（被保护，不能成为对方选择的对象或攻击目标）。
function c42166000.tgtg(e,c)
	return not (c:IsCode(42166000) and c:IsFaceup())
end
-- 子组检查函数：检查一组解放素材中是否包含至少1只「神·史莱姆」，并且该组素材可以作为要召唤怪兽的祭品。
function c42166000.gchk(g,tc,tp)
	-- 返回条件：解放素材组g中存在1只满足ttfilter的「神·史莱姆」，且g整体满足Duel.CheckTribute（可解放且数量等于#g）。
	return g:IsExists(c42166000.ttfilter,1,nil,tp) and Duel.CheckTribute(tc,#g,#g,g)
end
-- 卡号5008836的怪兽的特殊召唤规则条件：当所需解放数不超过5时，从自己场上选择3只怪兽作为解放素材，其中必须包含1只「神·史莱姆」，以代替其5只解放数量。
function c42166000.t5con(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上的全部怪兽组，用于从中选择解放素材。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return minc<=5 and g:CheckSubGroup(c42166000.gchk,3,3,c,tp)
end
-- 对卡号5008836的怪兽的上级召唤操作：先选择2只普通解放，再选择1只「神·史莱姆」，合并后解放，以完成需要5只解放的上级召唤。
function c42166000.t5op(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择2只怪兽作为通常的解放祭品（与1只「神·史莱姆」合计代替5只解放）。
	local g=Duel.SelectTribute(tp,c,2,2)
	-- 弹出“请选择要解放的卡”的提示消息，引导玩家选择第1只普通解放。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 再从自己场上选择1只满足ttfilter条件的「神·史莱姆」作为解放素材。
	local sg=Duel.SelectMatchingCard(tp,c42166000.ttfilter,tp,LOCATION_MZONE,0,1,1,g,tp)
	g:Merge(sg)
	c:SetMaterial(g)
	-- 将这2只普通怪兽和1只「神·史莱姆」一并解放，作为需要5只解放的怪兽的上级召唤祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

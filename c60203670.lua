--GP－アサシネーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
-- ②：从自己的手卡·场上（表侧表示）·墓地把这张卡以外的1只「黄金荣耀」怪兽除外才能发动。把持有和除外的怪兽的等级相同等级的1只「黄金荣耀衍生物」（机械族·暗·攻/守0）在自己场上特殊召唤。这张卡在这个回合作为融合·同调·超量·连接召唤的素材的场合，不是「黄金荣耀」怪兽的融合·同调·超量·连接召唤不能使用。
local s,id,o=GetID()
-- 注册卡片效果：①手卡自身特招，②除外手卡/场上/墓地其他「黄金荣耀」怪兽特招同等级衍生物，并限制自身作为素材时的怪兽种类。
function s.initial_effect(c)
	-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上（表侧表示）·墓地把这张卡以外的1只「黄金荣耀」怪兽除外才能发动。把持有和除外的怪兽的等级相同等级的1只「黄金荣耀衍生物」（机械族·暗·攻/守0）在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.tokencost)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己基本分比对方少。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己当前生命值是否小于对方当前生命值。
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 效果①的发动准备与合法性检测：检查怪兽区域是否有空位，以及自身是否可以特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用于特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表明该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：若自身仍在手卡，则将自身特殊召唤。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤条件：手卡、场上、墓地中除自身以外的，等级在1以上、可以作为代价除外的「黄金荣耀」怪兽，且其等级对应的衍生物可以被特殊召唤。
function s.cfilter(c,tp)
	return c:IsSetCard(0x192) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsLevelAbove(1) and c:IsFaceupEx()
		-- 检查玩家是否能特殊召唤对应等级的衍生物，并确保该卡离开后有可用的怪兽区域。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_MACHINE,ATTRIBUTE_DARK) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的代价处理：从手卡、场上、墓地选择1只除自身以外的「黄金荣耀」怪兽除外，并记录其等级。
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 检查手卡、场上、墓地是否存在满足过滤条件的「黄金荣耀」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,c,tp) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张满足条件的「黄金荣耀」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c,tp):GetFirst()
	e:SetLabel(tc:GetLevel())
	-- 将选中的怪兽表侧表示除外作为发动代价。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与合法性检测：检查是否支付了代价，并设置特殊召唤衍生物的连锁信息。
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		return res
	end
	-- 设置连锁信息，表明该效果包含产生衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息，表明该效果包含特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的处理：在自己场上特殊召唤1只与除外怪兽等级相同的「黄金荣耀衍生物」，并对自身施加素材限制。
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检查自己场上是否有可用于特殊召唤怪兽的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该属性、种族、等级和攻守的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,lv,RACE_MACHINE,ATTRIBUTE_DARK) then
		-- 在内存中创建对应的衍生物卡片。
		local tk=Duel.CreateToken(tp,id+o)
		-- 把持有和除外的怪兽的等级相同等级的1只「黄金荣耀衍生物」（机械族·暗·攻/守0）在自己场上特殊召唤。这张卡在这个回合作为融合·同调·超量·连接召唤的素材的场合，不是「黄金荣耀」怪兽的融合·同调·超量·连接召唤不能使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(lv)
		tk:RegisterEffect(e1,true)
		-- 将衍生物以表侧表示特殊召唤到自己场上（单步处理）。
		Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
	-- 这张卡在这个回合作为融合·同调·超量·连接召唤的素材的场合，不是「黄金荣耀」怪兽的融合·同调·超量·连接召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.synlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetValue(s.fsynlimit)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e5)
end
-- 同调素材限制：不能作为「黄金荣耀」怪兽以外的怪兽的同调素材。
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x192)
end
-- 融合素材限制：不能作为「黄金荣耀」怪兽以外的怪兽的融合素材。
function s.fsynlimit(e,c,sumtype)
	if not c then return false end
	return sumtype==SUMMON_TYPE_FUSION and not c:IsSetCard(0x192)
end

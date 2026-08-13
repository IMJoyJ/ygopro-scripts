--電脳堺嫦－兎々
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有念动力族·幻龙族怪兽的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1只念动力族·幻龙族怪兽才能发动。这张卡当作调整使用特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c20799347.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有念动力族·幻龙族怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20799347,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c20799347.ntcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，从手卡丢弃1只念动力族·幻龙族怪兽才能发动。这张卡当作调整使用特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20799347,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20799347)
	e2:SetCost(c20799347.spcost)
	e2:SetTarget(c20799347.sptg)
	e2:SetOperation(c20799347.spop)
	c:RegisterEffect(e2)
end
c20799347.treat_itself_tuner=true
-- 筛选条件：检查怪兽是否为里侧表示或种族不是念动力族·幻龙族，用于判断场上是否满足“只有念动力族·幻龙族怪兽”。
function c20799347.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_PSYCHO+RACE_WYRM)
end
-- 无解放召唤条件：要求怪兽等级5以上、主要怪兽区有空位，且自己场上没有怪兽或所有表侧怪兽均为念动力族·幻龙族，从而允许不解放召唤。
function c20799347.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 要求此次召唤解放数为0、怪兽等级不低于5，且自己场上存在可用的主要怪兽区域。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 要求自己场上没有怪兽，或不存在里侧表示/非念动力族·幻龙族的怪兽，即满足“自己场上怪兽不存在或只有念动力族·幻龙族怪兽”。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c20799347.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 代价筛选：手卡中为念动力族·幻龙族且可以丢弃的怪兽，作为发动②的代价。
function c20799347.costfilter(c)
	return c:IsRace(RACE_PSYCHO+RACE_WYRM) and c:IsDiscardable()
end
-- ②的代价：从手卡丢弃1只念动力族·幻龙族怪兽；chk==0时检查可行性，执行时丢弃1张。
function c20799347.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法检查：确认手卡中存在1只可丢弃的念动力族·幻龙族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20799347.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择并丢弃1只念动力族·幻龙族怪兽，丢弃原因标记为发动代价（COST）并包含丢弃原因。
	Duel.DiscardHand(tp,c20799347.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤目标判定：不取对象；检查自己主要怪兽区有空格且该卡能够被特殊召唤。
function c20799347.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格，以能够特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将特殊召唤这张卡自身，数量为1，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：这张卡仍与效果关联时将其表侧特殊召唤；召唤成功则附加“当作调整使用”和“离场时除外”效果；最后为本回合附加“不能特殊召唤等级/阶级3以下怪兽”的自肃效果。
function c20799347.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡未被无效且仍关联本效果，然后以表侧表示将其特殊召唤；只有特殊召唤成功才继续附加后续效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- “这张卡当作调整使用特殊召唤。”——从特殊召唤成功开始，这张卡视为调整怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		-- “这个效果特殊召唤的这张卡从场上离开的场合除外。”——设置离场时不去墓地而是除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- “这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。”——设置本回合的召唤限制：只能特殊召唤等级或阶级3以上的怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c20799347.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前玩家，效果持续到结束阶段。
	Duel.RegisterEffect(e3,tp)
end
-- 限制判定：被特殊召唤的怪兽的等级和阶级均低于3时禁止特殊召唤；等级或阶级在3以上则允许。
function c20799347.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end

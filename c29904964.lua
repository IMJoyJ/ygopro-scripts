--覚醒の暗黒騎士ガイア
-- 效果：
-- 「觉醒的暗黑骑士 盖亚」的②的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以不用解放作召唤。
-- ②：这张卡被解放的场合才能发动。从自己的手卡·墓地选1只「混沌战士」怪兽特殊召唤。
-- ③：「混沌战士」怪兽的仪式召唤进行的场合，可以作为需要的等级数值的怪兽之内的1只，把墓地的这张卡除外。
function c29904964.initial_effect(c)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29904964,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c29904964.ntcon)
	c:RegisterEffect(e1)
	-- 「觉醒的暗黑骑士 盖亚」的②的效果1回合只能使用1次。②：这张卡被解放的场合才能发动。从自己的手卡·墓地选1只「混沌战士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29904964,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,29904964)
	e2:SetTarget(c29904964.sptg)
	e2:SetOperation(c29904964.spop)
	c:RegisterEffect(e2)
	-- ③：「混沌战士」怪兽的仪式召唤进行的场合，可以作为需要的等级数值的怪兽之内的1只，把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetValue(c29904964.mtval)
	c:RegisterEffect(e3)
end
-- 该召唤规则效果的条件函数：若系统询问是否可以适用该召唤方式（c==nil）则返回true；否则要求无需解放、这张卡等级5以上、自己主要怪兽区有空位，且对方场上的怪兽数量多于自己场上的怪兽。
function c29904964.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 满足召唤条件的基础部分：该召唤不需要解放，且这张卡为等级5以上，同时自己主要怪兽区有空位可供通常召唤。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 满足召唤条件的数量对比部分：对方场上的怪兽数量比自己场上的怪兽数量更多，这是不用解放召唤的前提。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 特殊召唤候选怪兽的过滤条件：卡片属于「混沌战士」字段（setcode 0x10cf），并且能够被当前效果正常特殊召唤（满足召唤条件与苏生限制）。
function c29904964.spfilter(c,e,tp)
	return c:IsSetCard(0x10cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标检查与操作信息设置：先确认手卡·墓地是否存在符合条件的「混沌战士」怪兽，若存在则设置本次操作信息为从手卡·墓地特殊召唤1只怪兽。
function c29904964.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）判定：自己手卡·墓地是否存在至少1只满足spfilter条件的「混沌战士」怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29904964.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：该连锁的处理包含特殊召唤类别，预定从手卡·墓地特殊召唤1只怪兽（具体对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时的操作函数：由玩家选择1只符合条件的「混沌战士」怪兽，并将其表侧表示特殊召唤到自己场上。
function c29904964.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只满足spfilter且不受王家长眠之谷等效果影响的「混沌战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29904964.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（特殊召唤给tp，并正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 该Value函数用于判断墓地的这张卡能否作为仪式召唤素材：当进行仪式召唤的怪兽是「混沌战士」字段（setcode 0x10cf）怪兽时返回true，即可以作为所需等级数值的1只素材被除外。
function c29904964.mtval(e,c)
	return c:IsSetCard(0x10cf)
end

--地縛囚人 グランド・キーパー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「地缚囚人 土地看守者」外的1只5星以下的「地缚」怪兽从自己的卡组·墓地特殊召唤。这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
-- ②：只要场地区域有卡存在，自己场上的「地缚」怪兽不会被战斗·效果破坏。
local s,id,o=GetID()
-- 注册该卡的①和②效果：①在召唤·特殊召唤成功时可发动，从卡组·墓地特殊召唤1只5星以下除自身外的「地缚」怪兽，发动后直到回合结束时自己不能从额外卡组特殊召唤融合·同调以外的怪兽；②只要场地区域有卡存在，自己场上的「地缚」怪兽不会被战斗·效果破坏。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。除「地缚囚人 土地看守者」外的1只5星以下的「地缚」怪兽从自己的卡组·墓地特殊召唤。这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要场地区域有卡存在，自己场上的「地缚」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选自己场上所有持有「地缚」字段的怪兽，作为②效果的保护对象。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x21))
	e3:SetValue(s.indcon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
-- 定义①特殊召唤的检索条件：等级5以下、持有「地缚」字段、能被效果特殊召唤，且不是本卡（地缚囚人 土地看守者）。
function s.filter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id)
end
-- ①效果发动时的合法性检查：自己主要怪兽区有空位，并且卡组·墓地存在1只符合条件的「地缚」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空位，以确保特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组·墓地是否存在至少1只满足 s.filter 条件的「地缚」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次效果处理的操作信息：从卡组·墓地特殊召唤1只怪兽（用于让其他卡检测本次效果类别与数量）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理①效果：有空格时从卡组·墓地特殊召唤1只符合条件的「地缚」怪兽；并给自己附加自肃效果，直到回合结束时不能从额外卡组特殊召唤融合·同调以外的怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的主要怪兽区域，防止在连锁处理中空位被占用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家显示选择提示，提示正在选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的卡组·墓地中，选择1张满足条件且不受「王家长眠之谷」影响的「地缚」怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。②：只要场地区域有卡存在，自己场上的「地缚」怪兽不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家，使其在回合结束前受到相应特殊召唤限制。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制的对象：额外卡组中的非融合·非同调怪兽不能特殊召唤。
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 定义②的适用条件：双方场地区域合计存在至少1张卡。
function s.indcon(e,c)
	-- 返回双方场地区域卡的数量是否大于0，即只要任意一方场地区有卡就满足条件。
	return Duel.GetFieldGroupCount(0,LOCATION_FZONE,LOCATION_FZONE)>0
end

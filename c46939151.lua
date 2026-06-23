--地縛囚人 グランド・キーパー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「地缚囚人 土地看守者」外的1只5星以下的「地缚」怪兽从自己的卡组·墓地特殊召唤。这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
-- ②：只要场地区域有卡存在，自己场上的「地缚」怪兽不会被战斗·效果破坏。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括召唤成功和特殊召唤成功时触发的效果，以及场地区域怪兽不被破坏的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
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
	-- 只要场地区域有卡存在，自己场上的「地缚」怪兽不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为所有「地缚」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x21))
	e3:SetValue(s.indcon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选满足条件的「地缚」怪兽（5星以下、可特殊召唤、非本卡）
function s.filter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id)
end
-- 判断是否可以发动效果：场上存在空位且自己卡组或墓地存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己卡组或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：若场上存在空位，则从卡组或墓地选择一只符合条件的怪兽特殊召唤，并在回合结束时禁止自己从额外卡组特殊召唤非融合/同调怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组或墓地选择一只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标为位于额外卡组且非融合/同调类型的怪兽
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 判断场地区域是否存在卡
function s.indcon(e,c)
	-- 判断场地区域是否存在卡
	return Duel.GetFieldGroupCount(0,LOCATION_FZONE,LOCATION_FZONE)>0
end

--レッド・ノヴァ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场上有8星以上的龙族同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：调整2只以上为素材的同调召唤让这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只恶魔族·炎属性怪兽守备表示特殊召唤。
function c21142671.initial_effect(c)
	-- 对应效果原文：「这个卡名的①的方法的特殊召唤1回合只能有1次。」「①：场上有8星以上的龙族同调怪兽存在的场合，这张卡可以从手卡特殊召唤。」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21142671+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21142671.spcon)
	c:RegisterEffect(e1)
	-- 对应效果原文：「②：调整2只以上为素材的同调召唤让这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只恶魔族·炎属性怪兽守备表示特殊召唤。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21142671,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c21142671.spdcon)
	e2:SetTarget(c21142671.spdtg)
	e2:SetOperation(c21142671.spdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：满足表侧表示、同调怪兽、8星以上、龙族。
function c21142671.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON)
end
-- 特殊召唤规则条件：当需要实际特殊召唤时，确认我方主要怪兽区有空位，且我方或对方场上有至少1只表侧表示8星以上的龙族同调怪兽；若只是检查效果本身，则直接返回true。
function c21142671.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认我方主要怪兽区存在可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认场上存在至少1只表侧表示且等级8以上的龙族同调怪兽。
		and Duel.IsExistingMatchingCard(c21142671.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 发动条件：这张卡位于墓地，且是作为同调素材被送去墓地（REASON_SYNCHRO），并且导致其送去墓地的同调召唤怪兽带有21142671号效果标记，以确认该同调召唤使用了这张卡。
function c21142671.spdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsHasEffect(21142671)
end
-- 选择条件：卡组中的恶魔族·炎属性怪兽，且能够以表侧守备表示特殊召唤（正常检查召唤条件与苏生限制）。
function c21142671.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的目标检查：若为合法性判定，则要求我方主要怪兽区有空位，且卡组存在符合条件的恶魔族·炎属性怪兽。
function c21142671.spdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时确认：我方主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1张满足filter的恶魔族·炎属性怪兽。
		and Duel.IsExistingMatchingCard(c21142671.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将把1只怪兽从卡组特殊召唤（具体怪兽在效果处理时选择，因此目标暂为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若我方主要怪兽区仍有空位，则选择卡组中1只符合条件的恶魔族·炎属性怪兽，并以表侧守备表示特殊召唤。
function c21142671.spdop(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区已无空位，则不进行后续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足filter的恶魔族·炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c21142671.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

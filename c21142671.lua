--レッド・ノヴァ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场上有8星以上的龙族同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：调整2只以上为素材的同调召唤让这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只恶魔族·炎属性怪兽守备表示特殊召唤。
function c21142671.initial_effect(c)
	-- ①：场上有8星以上的龙族同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21142671+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21142671.spcon)
	c:RegisterEffect(e1)
	-- ②：调整2只以上为素材的同调召唤让这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只恶魔族·炎属性怪兽守备表示特殊召唤。
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
-- 过滤函数，用于判断场上是否存在8星以上的龙族同调怪兽。
function c21142671.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON)
end
-- 判断是否满足①效果的特殊召唤条件，即场上有8星以上的龙族同调怪兽且有空场。
function c21142671.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家的场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在满足条件的龙族同调怪兽。
		and Duel.IsExistingMatchingCard(c21142671.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 判断是否满足②效果的发动条件，即此卡因同调召唤被送去墓地且其同调怪兽具有此卡效果。
function c21142671.spdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsHasEffect(21142671)
end
-- 过滤函数，用于筛选卡组中满足条件的恶魔族·炎属性怪兽。
function c21142671.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置②效果的发动条件，检查是否有满足条件的怪兽可特殊召唤。
function c21142671.spdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在满足条件的恶魔族·炎属性怪兽。
		and Duel.IsExistingMatchingCard(c21142671.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，执行从卡组特殊召唤恶魔族·炎属性怪兽的操作。
function c21142671.spdop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的场上是否有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的恶魔族·炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c21142671.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

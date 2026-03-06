--白き森のアステーリャ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。从卡组把1只魔法师族·光属性调整特殊召唤。
-- ②：这张卡在墓地存在的状态，魔法·陷阱卡为让怪兽的效果发动而被送去自己墓地的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。从卡组把1只魔法师族·光属性调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，魔法·陷阱卡为让怪兽的效果发动而被送去自己墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的魔法·陷阱卡（可送入墓地作为费用且场上怪兽区有空位）
function s.spcfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 满足条件的魔法·陷阱卡可送入墓地作为费用且场上怪兽区有空位
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 检查是否有满足条件的魔法·陷阱卡可作为费用送入墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 提示玩家选择要送入墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	-- 选择要送入墓地的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 将选中的魔法·陷阱卡送入墓地作为费用
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	-- 过滤满足条件的魔法师族·光属性调整
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检查卡组中是否存在满足条件的魔法师族·光属性调整
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_SPELLCASTER)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的魔法师族·光属性调整
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 检查场上怪兽区是否有空位
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的魔法师族·光属性调整
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 选择要特殊召唤的魔法师族·光属性调整
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 执行特殊召唤操作
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 过滤满足条件的魔法·陷阱卡（因怪兽效果发动而送入墓地）
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查是否有满足条件的魔法·陷阱卡因怪兽效果发动而送入墓地
function s.spfilter2(c,re,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsControler(tp)
		and c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) or bit.band(c:GetPreviousTypeOnField(),TYPE_SPELL+TYPE_TRAP)~=0)
end
-- 检查场上是否存在满足条件的魔法·陷阱卡
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter2,1,nil,re,tp)
end
-- 检查墓地中的卡是否可以特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

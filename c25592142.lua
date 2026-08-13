--白き森のアステーリャ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。从卡组把1只魔法师族·光属性调整特殊召唤。
-- ②：这张卡在墓地存在的状态，魔法·陷阱卡为让怪兽的效果发动而被送去自己墓地的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册该卡的两个效果：①为起动效果，从自己手卡·场上把1张魔法·陷阱卡送去墓地，从卡组特殊召唤1只魔法师族·光属性调整；②为墓地诱发效果，当魔法·陷阱卡为让怪兽的效果发动而被送去自己墓地时，自身特殊召唤；两个效果1回合各能使用1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。从卡组把1只魔法师族·光属性调整特殊召唤。
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
-- 定义①效果代价的筛选条件：选择自己手牌·场上的1张魔法·陷阱卡，该卡可作为代价送去墓地，且该卡离开后自己场上仍有可用怪兽区。
function s.spcfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 同时满足：该魔法·陷阱卡可以作为代价送去墓地，并且该卡离开后自己场上仍有怪兽区空格，确保后续特殊召唤有位置。
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 支付①效果的发动代价：从自己手卡·场上选择1张魔法·陷阱卡送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时合法性检查：确认自己手卡·场上存在至少1张满足spcfilter的魔法·陷阱卡可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	-- 向玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己手卡·场上选择1张满足条件的魔法·陷阱卡作为代价。
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	-- 将选择的卡以『代价』原因送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义①效果特殊召唤的目标筛选条件：必须是魔法师族、光属性、调整怪兽，且可以被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_SPELLCASTER)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标/发动条件设定：检查卡组是否存在符合条件的怪兽；若存在，则设置操作信息，告知系统本次将进行从卡组的特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在至少1只满足条件的魔法师族·光属性调整。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将进行1次从卡组的特殊召唤（目标暂不确定，所以目标为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：实际从卡组选择1只符合条件的怪兽，以表侧攻击表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己怪兽区是否有空位，若无则终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的触发素材判定：被送去墓地的卡需是自己控制的魔法·陷阱卡，因作为cost被送去，且发动该效果的卡是怪兽效果；若从场上送去，还需确认其在场上时也是魔法·陷阱卡。
function s.spfilter2(c,re,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsControler(tp)
		and c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) or bit.band(c:GetPreviousTypeOnField(),TYPE_SPELL+TYPE_TRAP)~=0)
end
-- ②效果的发动条件：本次被送去墓地的卡中存在至少1张满足spfilter2的魔法·陷阱卡，即满足『魔法·陷阱卡为让怪兽的效果发动而被送去自己墓地』。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter2,1,nil,re,tp)
end
-- ②效果发动时检查：自己场上存在可用的怪兽区空格，且这张卡自身可以被特殊召唤（满足苏生限制等），才可发动。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上有可用怪兽区，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张墓地中的卡确定为即将特殊召唤的对象，类别为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联（未离场或未被除外等），将其特殊召唤到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

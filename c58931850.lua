--超究極魔導竜王
-- 效果：
-- 12星怪兽×2
-- ①：只要超量召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：只要自己墓地有卡25张以上存在，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
-- ③：1回合1次，对方墓地有卡25张以上存在的场合，把这张卡1个超量素材取除才能发动。从自己的卡组·额外卡组·墓地把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含XYZ召唤手续、抗性、双倍贯穿伤害以及特殊召唤效果。
function s.initial_effect(c)
	-- 设置XYZ召唤手续：12星怪兽×2。
	aux.AddXyzProcedure(c,nil,12,2)
	c:EnableReviveLimit()
	-- ①：只要超量召唤的这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.valcon)
	-- 设置不能成为对方卡的效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ①：只要超量召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.valcon)
	-- 设置不会被对方的效果破坏。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要自己墓地有卡25张以上存在，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetValue(DOUBLE_DAMAGE)
	e3:SetCondition(s.atkcon)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方墓地有卡25张以上存在的场合，把这张卡1个超量素材取除才能发动。从自己的卡组·额外卡组·墓地把1只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.spcon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 限制抗性效果仅在超量召唤成功时适用。
function s.valcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 贯穿伤害效果的发动条件：自己墓地有卡25张以上存在。
function s.atkcon(e)
	-- 检查自己墓地的卡片数量是否在25张以上。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,0)>=25
end
-- 特殊召唤效果的发动条件：对方墓地有卡25张以上存在。
function s.spcon(e)
	-- 检查对方墓地的卡片数量是否在25张以上。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)>=25
end
-- 特殊召唤效果的发动代价：取除这张卡的1个超量素材。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：检查卡片是否可以特殊召唤，并根据其所在位置（卡组/墓地或额外卡组）判断是否有可用的怪兽区域。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若卡片在卡组或墓地，则需要自己场上有可用的主要怪兽区域。
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，则需要有可用于从额外卡组特殊召唤该怪兽的区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 特殊召唤效果的发动准备（Target）：检查是否存在可特殊召唤的怪兽，并向双方玩家宣告该效果包含特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组、额外卡组、墓地是否存在至少1只满足特殊召唤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁信息，表明此效果会从卡组、额外卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 特殊召唤效果的效果处理（Operation）：从卡组、额外卡组或墓地选择1只怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组、额外卡组或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--アマゾネス女帝
-- 效果：
-- 「亚马逊女王」＋「亚马逊」怪兽
-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会被战斗·效果破坏。
-- ②：自己的「亚马逊」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「亚马逊女王」特殊召唤。
function c4591250.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为15951532的怪兽和1个融合种族为亚马逊的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,15951532,aux.FilterBoolFunction(Card.IsFusionSetCard,0x4),1,true,true)
	-- 只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c4591250.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 自己的「亚马逊」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有亚马逊族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
	c:RegisterEffect(e3)
	-- 融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「亚马逊女王」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4591250,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c4591250.spcon)
	e4:SetTarget(c4591250.sptg)
	e4:SetOperation(c4591250.spop)
	c:RegisterEffect(e4)
end
-- 效果目标为场上所有亚马逊族怪兽且不包括自身
function c4591250.indtg(e,c)
	return c:IsSetCard(0x4) and c~=e:GetHandler()
end
-- 效果发动条件：此卡为融合召唤且因战斗或对方效果离场且为表侧表示
function c4591250.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
		and (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数，用于筛选可特殊召唤的亚马逊女王（卡号15951532）
function c4591250.filter(c,e,tp)
	return c:IsCode(15951532) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在可特殊召唤的亚马逊女王且有空场
function c4591250.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在可特殊召唤的亚马逊女王且有空场
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：场上存在可特殊召唤的亚马逊女王且有空场
		and Duel.IsExistingMatchingCard(c4591250.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的亚马逊女王
function c4591250.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件：场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的亚马逊女王
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4591250.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

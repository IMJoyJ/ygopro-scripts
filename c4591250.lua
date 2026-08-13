--アマゾネス女帝
-- 效果：
-- 「亚马逊女王」＋「亚马逊」怪兽
-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会被战斗·效果破坏。
-- ②：自己的「亚马逊」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「亚马逊女王」特殊召唤。
function c4591250.initial_effect(c)
	c:EnableReviveLimit()
	-- 为亚马逊女帝注册融合召唤手续：融合素材为1只「亚马逊女王」（15951532）和1只「亚马逊」字段（0x4）怪兽，共1只字段素材，允许使用替换素材/融合素材置换。
	aux.AddFusionProcCodeFun(c,15951532,aux.FilterBoolFunction(Card.IsFusionSetCard,0x4),1,true,true)
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会被战斗·效果破坏。（本段代码对应其中“不会被战斗破坏”的部分）
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
	-- ②：自己的「亚马逊」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯穿伤害效果的适用对象为持有「亚马逊」字段（0x4）的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
	c:RegisterEffect(e3)
	-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「亚马逊女王」特殊召唤。
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
-- 判断某张卡是否为这张卡以外的自己场上的「亚马逊」卡：满足「亚马逊」字段（0x4）且不是效果持有者自身。
function c4591250.indtg(e,c)
	return c:IsSetCard(0x4) and c~=e:GetHandler()
end
-- ③的发动条件：这张卡是以融合召唤方式出场、离场前为表侧表示，并且因对方的效果离场（对方玩家发动效果导致）或因战斗被破坏。
function c4591250.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
		and (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选可特殊召唤的「亚马逊女王」：卡号必须为15951532，并且能够以通常方式特殊召唤（检查召唤条件与苏生限制）。
function c4591250.filter(c,e,tp)
	return c:IsCode(15951532) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动目标判定：进行效果发动合法性检查，需要自己主要怪兽区有空位，且手卡·卡组·墓地存在至少1只满足条件的「亚马逊女王」。
function c4591250.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手卡·卡组·墓地是否存在至少1只满足特殊召唤条件的「亚马逊女王」。
		and Duel.IsExistingMatchingCard(c4591250.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设定效果处理信息：本次操作包含特殊召唤，从持有者的手卡·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ③的效果处理：先确保主要怪兽区有空位，再让玩家从手卡·卡组·墓地（受王家长眠之谷等效果影响后仍可选）选择1只「亚马逊女王」表侧表示特殊召唤到自己场上。
function c4591250.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区是否有空格，无空格则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·卡组·墓地中选择1只满足条件的「亚马逊女王」，且过滤掉受王家长眠之谷影响不能从墓地特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4591250.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「亚马逊女王」以表侧攻击表示特殊召唤到自己场上，检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

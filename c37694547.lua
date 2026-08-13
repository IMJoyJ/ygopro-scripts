--歯車街
-- 效果：
-- ①：只要这张卡在场地区域存在，双方玩家可以把「古代的机械」怪兽召唤的场合需要的解放减少1只。
-- ②：这张卡被破坏送去墓地时才能发动。从自己的手卡·卡组·墓地把1只「古代的机械」怪兽特殊召唤。
function c37694547.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，双方玩家可以把「古代的机械」怪兽召唤的场合需要的解放减少1只。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	-- 指定减少祭品效果的作用范围为双方手牌中所有「古代的机械」字段的怪兽，使其召唤时所需解放数减少。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7))
	e2:SetValue(c37694547.decval)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏送去墓地时才能发动。从自己的手卡·卡组·墓地把1只「古代的机械」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(37694547,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c37694547.spcon)
	e3:SetTarget(c37694547.sptg)
	e3:SetOperation(c37694547.spop)
	c:RegisterEffect(e3)
end
-- 返回减解放数量1和效果来源卡编号37694547，使齿车街的减祭品效果不重复叠加。
function c37694547.decval(e,c)
	return 0x1,37694547
end
-- 发动条件判定：判断齿车街是否因被破坏而送去墓地，只有满足时才可发动特殊召唤效果。
function c37694547.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 定义可特殊召唤的怪兽条件：必须是「古代的机械」字段的怪兽，且能被当前效果特殊召唤。
function c37694547.filter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性检查：自场上有可用主怪兽区，且手牌·卡组·墓地存在符合条件的「古代的机械」怪兽。
function c37694547.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空的怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 从手牌·卡组·墓地（0x13）中检查是否存在至少1只满足特殊召唤条件的「古代的机械」怪兽。
		and Duel.IsExistingMatchingCard(c37694547.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁为特殊召唤，预计从自己的手牌·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理：选1只符合条件的「古代的机械」怪兽，从手牌·卡组·墓地特殊召唤到自己场上，然后洗切卡组。
function c37694547.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己手牌·卡组·墓地中挑选1张符合条件的「古代的机械」怪兽；墓地的卡还需绕过王家长眠之谷的限制。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37694547.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上，并检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 洗切自己的卡组，因为特殊召唤可能从卡组取卡。
		Duel.ShuffleDeck(tp)
	end
end

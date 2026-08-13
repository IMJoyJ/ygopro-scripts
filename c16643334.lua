--輝光竜フォトン・ブラスト・ドラゴン
-- 效果：
-- 4星怪兽×2
-- ①：这张卡超量召唤的场合才能发动。从手卡把1只「光子」怪兽特殊召唤。
-- ②：只要超量召唤的这张卡在怪兽区域存在，自己场上的攻击力2000以上的怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
-- ③：对方回合1次，把这张卡1个超量素材取除，以自己的墓地·除外状态的1只「银河眼光子龙」为对象才能发动。那只怪兽特殊召唤。
function c16643334.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只4星怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从手卡把1只「光子」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16643334,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c16643334.spcon1)
	e1:SetTarget(c16643334.sptg1)
	e1:SetOperation(c16643334.spop1)
	c:RegisterEffect(e1)
	-- 只要超量召唤的这张卡在怪兽区域存在，自己场上的攻击力2000以上的怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c16643334.indcon)
	-- 该效果只适用于己方场上攻击力2000以上的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttackAbove,2000))
	-- 指定免疫值为：来自对方的效果造成的破坏无效（即不会被我方玩家的效果破坏）。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 只要超量召唤的这张卡在怪兽区域存在，对方不能把自己场上的攻击力2000以上的怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c16643334.indcon)
	-- 该效果只适用于己方场上攻击力2000以上的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttackAbove,2000))
	-- 指定对象防御值为：对方不能把这些怪兽作为效果对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：对方回合1次，把这张卡1个超量素材取除，以自己的墓地·除外状态的1只「银河眼光子龙」为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16643334,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e4:SetCondition(c16643334.spcon2)
	e4:SetCost(c16643334.spcost2)
	e4:SetTarget(c16643334.sptg2)
	e4:SetOperation(c16643334.spop2)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：这张卡以超量召唤方式召唤成功。
function c16643334.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤手牌中的「光子」怪兽，且该怪兽可以被这次效果特殊召唤。
function c16643334.spfilter1(c,e,tp)
	return c:IsSetCard(0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动合法性检查：己方主怪兽区有空位，且手牌存在1只满足条件的「光子」怪兽。
function c16643334.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在至少1只满足条件（「光子」字段且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c16643334.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次操作信息：效果处理时将把手卡的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①处理：从手卡选择1只「光子」怪兽，以表侧攻击表示特殊召唤到自己场上。
function c16643334.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主怪兽区有空位，没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中筛选并选择1只满足条件的「光子」怪兽。
	local g=Duel.SelectMatchingCard(tp,c16643334.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的适用条件：这张卡是超量召唤状态（即以此卡超量召唤成功为前提）。
function c16643334.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ③效果的发动条件：当前是对方的回合。
function c16643334.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是己方，即满足“对方回合”的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ③效果的发动代价：从这张卡上取除1个超量素材（作为发动COST）。
function c16643334.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选对象：自己墓地或除外区域的表侧表示的「银河眼光子龙」，且能够被这次效果特殊召唤。
function c16643334.spfilter2(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动合法性检查：己方主怪兽区有空位，且存在1只满足条件的「银河眼光子龙」可以选择为对象。
function c16643334.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c16643334.spfilter2(chkc,e,tp) end
	-- 检查己方主要怪兽区是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地·除外状态是否存在至少1只满足条件的「银河眼光子龙」可作为对象。
		and Duel.IsExistingTarget(c16643334.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地·除外状态选择1只满足条件的「银河眼光子龙」作为效果对象。
	local g=Duel.SelectTarget(tp,c16643334.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记本次操作信息：将把选定的对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：取得对象并将其特殊召唤到自己场上，若对象与效果仍关联。
function c16643334.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

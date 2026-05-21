--星遺物－『星杖』
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：通常召唤的这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
-- ②：这张卡被送去墓地的场合才能发动。从手卡把1只「星遗物」怪兽特殊召唤。
-- ③：把墓地的这张卡除外，以自己的除外状态的1只「自奏圣乐」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c93920420.initial_effect(c)
	-- ①：通常召唤的这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c93920420.indcon)
	e1:SetValue(c93920420.indlimit)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从手卡把1只「星遗物」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93920420,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,93920420)
	e2:SetTarget(c93920420.sptg1)
	e2:SetOperation(c93920420.spop1)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己的除外状态的1只「自奏圣乐」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93920420,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,93920421)
	-- 把墓地的这张卡除外作为发动效果的cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c93920420.sptg2)
	e3:SetOperation(c93920420.spop2)
	c:RegisterEffect(e3)
end
-- 判断这张卡是否为通常召唤（非特殊召唤）
function c93920420.indcon(e)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_SPECIAL)==0
end
-- 判断与之战斗的怪兽是否是从额外卡组特殊召唤的怪兽
function c93920420.indlimit(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤手卡中可以特殊召唤的「星遗物」怪兽
function c93920420.spfilter1(c,e,tp)
	return c:IsSetCard(0xfe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测
function c93920420.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测手卡中是否存在可以特殊召唤的「星遗物」怪兽
		and Duel.IsExistingMatchingCard(c93920420.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤手卡怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理：从手卡特殊召唤1只「星遗物」怪兽
function c93920420.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空余的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「星遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c93920420.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己除外状态的可以特殊召唤的「自奏圣乐」怪兽
function c93920420.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x11b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备、对象选择与合法性检测
function c93920420.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c93920420.spfilter2(chkc,e,tp) end
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己除外状态的卡中是否存在可以特殊召唤的「自奏圣乐」怪兽
		and Duel.IsExistingTarget(c93920420.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外状态的1只「自奏圣乐」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93920420.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤该对象的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理：特殊召唤对象怪兽，并适用只能特殊召唤暗属性怪兽的限制
function c93920420.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c93920420.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该回合内不能特殊召唤暗属性以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非暗属性的怪兽
function c93920420.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end

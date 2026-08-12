--ハーピィ・チャネラー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：只要自己场上有龙族怪兽存在，这张卡的等级变成7星。
-- ③：从手卡丢弃1张「鹰身」卡才能发动。从卡组把「鹰身通灵师」以外的1只「鹰身」怪兽守备表示特殊召唤。
function c90238142.initial_effect(c)
	-- 这个卡名的③的效果1回合只能使用1次。③：从手卡丢弃1张「鹰身」卡才能发动。从卡组把「鹰身通灵师」以外的1只「鹰身」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90238142,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,90238142)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c90238142.spcost)
	e1:SetTarget(c90238142.sptg)
	e1:SetOperation(c90238142.spop)
	c:RegisterEffect(e1)
	-- 使当前卡片在场上或墓地存在时，其卡名被视作「鹰身女郎」（卡号76812113）。
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：只要自己场上有龙族怪兽存在，这张卡的等级变成7星。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c90238142.lvcon)
	e3:SetValue(7)
	c:RegisterEffect(e3)
end
-- 过滤手牌中属于「鹰身」字段且可以丢弃的卡片。
function c90238142.cfilter(c)
	return c:IsSetCard(0x64) and c:IsDiscardable()
end
-- 效果③的发动代价函数，用于检查并执行从手牌丢弃1张「鹰身」卡的操作。
function c90238142.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查手牌中是否存在除自身以外的「鹰身」卡可以丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c90238142.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中选择1张「鹰身」卡丢弃送去墓地作为发动的代价。
	Duel.DiscardHand(tp,c90238142.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中属于「鹰身」字段、卡名不是「鹰身通灵师」且可以守备表示特殊召唤的怪兽。
function c90238142.filter(c,e,tp)
	return c:IsSetCard(0x64) and not c:IsCode(90238142) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果③的发动准备函数，检查怪兽区域是否有空位以及卡组中是否存在可特召的怪兽，并设置特殊召唤的操作信息。
function c90238142.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有可用于特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c90238142.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理函数，执行从卡组守备表示特殊召唤怪兽的处理。
function c90238142.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上没有空余的怪兽区域，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「鹰身」怪兽。
	local g=Duel.SelectMatchingCard(tp,c90238142.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤自己场上表侧表示存在的龙族怪兽。
function c90238142.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果②的适用条件函数，检查自己场上是否存在龙族怪兽。
function c90238142.lvcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的龙族怪兽。
	return Duel.IsExistingMatchingCard(c90238142.lvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

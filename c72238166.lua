--ノード・ライゼオル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己的场上或墓地有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：从自己的手卡·场上把1张卡送去墓地，以「节式阳极雷火沸动机」以外的自己墓地1只「雷火沸动」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤的自身特召效果，②送墓手卡/场上的卡特召墓地「雷火沸动」怪兽的效果。
function s.initial_effect(c)
	-- ①：自己的场上或墓地有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把1张卡送去墓地，以「节式阳极雷火沸动机」以外的自己墓地1只「雷火沸动」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 自身特殊召唤效果的判定条件：自己场上或墓地存在超量怪兽，且自己场上有可用的怪兽区域。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上或墓地是否存在超量怪兽。
		and Duel.GetMatchingGroupCount(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,TYPE_XYZ)>0
end
-- 自身特殊召唤成功时的处理：注册一个本回合内限制自己从额外卡组特殊召唤非4阶超量怪兽的玩家效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。②：从自己的手卡·场上把1张卡送去墓地，以「节式阳极雷火沸动机」以外的自己墓地1只「雷火沸动」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制从额外卡组特殊召唤非4阶超量怪兽的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特召的过滤条件：不能特殊召唤额外卡组中非4阶超量的怪兽。
function s.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤手卡或场上可以送去墓地作为发动成本的卡，且该卡送墓后能空出可用的怪兽区域。
function s.cfilter1(c,tp)
	-- 检查卡片是否能作为成本送去墓地，且该卡离开场上后自己场上是否有可用的怪兽区域。
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的发动成本：从自己的手卡或场上将1张卡送去墓地。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1张满足送墓成本条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上的卡作为发动成本。
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡作为发动成本送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤墓地中除「节式阳极雷火沸动机」以外、可以守备表示特殊召唤的「雷火沸动」怪兽。
function s.spfilter2(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1be)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的靶向与发动准备：选择墓地中1只符合条件的「雷火沸动」怪兽作为对象，并设置特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只符合条件的「雷火沸动」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中1只符合条件的「雷火沸动」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽和数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽效果无效并守备表示特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍符合效果条件，并尝试将其以表侧守备表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end

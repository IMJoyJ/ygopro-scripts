--ドラゴンメイド・シュテルン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。「半龙女仆·星夜龙女」以外的自己的墓地·除外状态的1只「半龙女仆」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的龙族融合怪兽不会被对方的效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只4星以下的「半龙女仆」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册三个效果：①特殊召唤、②永续不被破坏、③战斗阶段结束时回到手卡并特殊召唤。
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。「半龙女仆·星夜龙女」以外的自己的墓地·除外状态的1只「半龙女仆」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的龙族融合怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	-- 设置不被效果破坏的过滤函数。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只4星以下的「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动费用：丢弃自身。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身丢入墓地作为效果①的发动费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果①的特殊召唤目标过滤函数：非星夜龙女、半龙女仆族、可特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动宣言：确认场上是否有满足条件的怪兽且有召唤空位。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否有召唤空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地或除外区是否有满足条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置效果①的处理信息：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果①的处理：选择并特殊召唤1只满足条件的怪兽。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否还有召唤空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的过滤函数：龙族融合怪兽。
function s.indtg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION)
end
-- 效果③的特殊召唤目标过滤函数：4星以下、半龙女仆族、可特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动宣言：确认是否能将自身回手并召唤1只满足条件的怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自身是否能回手。
	if chk==0 then return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
		-- 确认手牌中是否有满足条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果③的处理信息：将自身回手。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置效果③的处理信息：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果③的处理：将自身回手并特殊召唤1只满足条件的怪兽。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身是否还在场上且成功回手。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认是否在手牌且有召唤空位。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--宣告者の神巫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组·额外卡组把1只天使族怪兽送去墓地。这张卡的等级直到回合结束时上升那只怪兽的等级数值。
-- ②：这张卡被解放的场合才能发动。从手卡·卡组把「宣告者的神巫」以外的1只2星以下的天使族怪兽特殊召唤。
function c92919429.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组·额外卡组把1只天使族怪兽送去墓地。这张卡的等级直到回合结束时上升那只怪兽的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92919429,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92919429)
	e1:SetTarget(c92919429.lvtg)
	e1:SetOperation(c92919429.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被解放的场合才能发动。从手卡·卡组把「宣告者的神巫」以外的1只2星以下的天使族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92919429,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,92919430)
	e3:SetTarget(c92919429.sptg)
	e3:SetOperation(c92919429.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组·额外卡组的天使族怪兽且可以送去墓地
function c92919429.lvfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGrave()
end
-- 效果①的发动准备（检查可行性并设置操作信息）
function c92919429.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足条件的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92919429.lvfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从卡组或额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果①的执行（送墓天使族怪兽并上升对应等级）
function c92919429.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c92919429.lvfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将该怪兽送去墓地，且该怪兽在墓地中且等级大于0
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and tc:GetLevel()>0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时上升那只怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：手卡·卡组中「宣告者的神巫」以外的2星以下的天使族怪兽且可以特殊召唤
function c92919429.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsLevelBelow(2) and not c:IsCode(92919429) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域空格及手卡·卡组中是否存在可特召的怪兽）
function c92919429.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡或卡组中存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c92919429.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的执行（特殊召唤手卡·卡组的天使族怪兽）
function c92919429.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92919429.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--H・C モーニング・スター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有战士族怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「英豪」魔法·陷阱卡加入手卡。
-- ③：这张卡在墓地存在，自己基本分是500以下的场合才能发动。这张卡效果无效特殊召唤。
local s,id,o=GetID()
-- 注册本卡的三个效果：①手卡起动效果特殊召唤自身；②召唤/特殊召唤成功时检索「英豪」魔法陷阱卡；③墓地起动效果特殊召唤自身并使其效果无效化。
function c18548966.initial_effect(c)
	-- ①：自己场上有战士族怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18548966)
	e1:SetCondition(c18548966.spcon)
	e1:SetTarget(c18548966.sptg)
	e1:SetOperation(c18548966.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「英豪」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,18548966+o)
	e2:SetTarget(c18548966.thtg)
	e2:SetOperation(c18548966.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在，自己基本分是500以下的场合才能发动。这张卡效果无效特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,18548966+o*2)
	e4:SetCondition(c18548966.rvcon)
	e4:SetTarget(c18548966.rvtg)
	e4:SetOperation(c18548966.rvop)
	c:RegisterEffect(e4)
end
-- 过滤器：筛选表侧表示且种族为战士族的怪兽。
function c18548966.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ①的发动条件：自己场上有战士族怪兽2只以上存在。
function c18548966.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区是否存在至少2只满足条件的战士族怪兽。
	return Duel.IsExistingMatchingCard(c18548966.filter,tp,LOCATION_MZONE,0,2,nil)
end
-- ①的发动时点处理：确认手卡的这张卡可以特殊召唤且自己主要怪兽区有空位，不取对象。
function c18548966.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己主要怪兽区有空位，且这张卡能被效果特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- ①：设置本次处理为特殊召唤这张卡的操作信息，使其他卡能响应此次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，则将其以表侧表示特殊召唤。
function c18548966.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤器：筛选卡名含有「英豪」字段的魔法·陷阱卡，且能够加入手卡。
function c18548966.thfilter(c)
	return c:IsSetCard(0x6f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②的发动时点处理：确认卡组中有满足条件的「英豪」魔法·陷阱卡，并设置检索操作信息。
function c18548966.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1张满足条件的「英豪」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c18548966.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- ②：设置操作信息：从卡组将1张卡加入手卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：从卡组选1张「英豪」魔法·陷阱卡加入手卡，并让对方确认。
function c18548966.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手卡的那张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组挑选1张满足条件的「英豪」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c18548966.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡，以进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③的发动条件：自己基本分在500以下。
function c18548966.rvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家当前基本分是否不超过500。
	return Duel.GetLP(tp)<=500
end
-- ③的发动时点处理：确认墓地中的这张卡可以特殊召唤且自己主要怪兽区有空位。
function c18548966.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己主要怪兽区有空位，且墓地中的这张卡能被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- ③：设置本次处理为特殊召唤这张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③的效果处理：将这张卡特殊召唤，并附加“效果无效”状态；最后完成特殊召唤流程。
function c18548966.rvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联，并尝试进行特殊召唤步骤；若成功则继续执行无效化处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- ③：这张卡效果无效特殊召唤。（对应“效果无效”：EFFECT_DISABLE）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ③：这张卡效果无效特殊召唤。（对应“效果无效”：EFFECT_DISABLE_EFFECT）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 完成本次特殊召唤流程的收尾处理（与SpecialSummonStep配合使用）。
	Duel.SpecialSummonComplete()
end

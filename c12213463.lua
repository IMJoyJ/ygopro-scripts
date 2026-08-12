--ホワイトローズ・ドラゴン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有龙族或植物族的调整存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤时才能发动。从自己的手卡·墓地把「白蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只4星以上的植物族怪兽送去墓地。
function c12213463.initial_effect(c)
	-- ①：自己场上有龙族或植物族的调整存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12213463,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12213463)
	e1:SetCondition(c12213463.spcon1)
	e1:SetTarget(c12213463.sptg1)
	e1:SetOperation(c12213463.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤时才能发动。从自己的手卡·墓地把「白蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12213463,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c12213463.sptg2)
	e2:SetOperation(c12213463.spop2)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只4星以上的植物族怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12213463,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,12213464)
	e3:SetCondition(c12213463.tgcon)
	e3:SetTarget(c12213463.tgtg)
	e3:SetOperation(c12213463.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在龙族或植物族的调整
function c12213463.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON+RACE_PLANT) and c:IsType(TYPE_TUNER)
end
-- 效果①的发动条件判断函数
function c12213463.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张龙族或植物族的调整
	return Duel.IsExistingMatchingCard(c12213463.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时点处理函数
function c12213463.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件：场上存在空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的发动信息，表示将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数
function c12213463.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于筛选「蔷薇龙」怪兽（除自身外）
function c12213463.spfilter(c,e,tp)
	return c:IsSetCard(0x1123) and not c:IsCode(12213463) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时点处理函数
function c12213463.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件：场上存在空位且存在符合条件的「蔷薇龙」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌或墓地是否存在至少1张符合条件的「蔷薇龙」怪兽
		and Duel.IsExistingMatchingCard(c12213463.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果②的发动信息，表示将特殊召唤1只「蔷薇龙」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的发动处理函数
function c12213463.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位，若无则不执行效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的「蔷薇龙」怪兽（排除受王家长眠之谷影响的卡）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12213463.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件判断函数
function c12213463.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于筛选4星以上且为植物族的怪兽
function c12213463.tgfilter(c)
	return c:IsLevelAbove(4) and c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 效果③的发动时点处理函数
function c12213463.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12213463.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果③的发动信息，表示将送去墓地1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果③的发动处理函数
function c12213463.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12213463.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--ガンホー！スプリガンズ！
-- 效果：
-- 4星「护宝炮妖」怪兽×2只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡超量召唤的场合或者被送去墓地的场合才能发动。从自己的卡组·墓地把1只「护宝炮妖船长 尾宿五」特殊召唤。
-- ②：把这张卡2个超量素材取除才能发动。从卡组选以下怪兽之内1只加入手卡或特殊召唤。
-- ●「护宝炮妖」怪兽
-- ●「兽带斗神」怪兽
-- ●「阿不思的落胤」或者有那个卡名记述的怪兽
local s,id,o=GetID()
-- 初始化效果函数，注册XYZ召唤手续并设置效果
function s.initial_effect(c)
	-- 记录该卡具有「护宝炮妖船长 尾宿五」和「阿不思的落胤」的卡名
	aux.AddCodeList(c,29601381,68468459)
	-- 设置XYZ召唤条件为4星且为「护宝炮妖」怪兽，需要2只以上怪兽叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x155),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 效果①：在被送去墓地时发动，从卡组或墓地特殊召唤「护宝炮妖船长 尾宿五」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	-- 效果②：支付2个超量素材，从卡组选择「护宝炮妖」、「兽带斗神」或「阿不思的落胤」怪兽加入手卡或特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 判断是否为XYZ召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足条件的「护宝炮妖船长 尾宿五」怪兽
function s.spfilter(c,e,tp)
	return c:IsCode(29601381) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果①的发动条件，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果①的处理信息，确定要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理效果①，选择并特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置效果②的发动费用，移除2个超量素材
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤满足条件的怪兽，包括「护宝炮妖」、「兽带斗神」或「阿不思的落胤」怪兽
function s.spfilter2(c,e,tp)
	-- 判断是否为「护宝炮妖」、「兽带斗神」或「阿不思的落胤」怪兽且为怪兽类型
	if not ((c:IsSetCard(0x155,0x179) or aux.IsCodeOrListed(c,68468459)) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置效果②的发动条件，检查卡组中是否有满足条件的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 处理效果②，选择怪兽并决定加入手卡或特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否可以将怪兽加入手卡或特殊召唤
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方看到该怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

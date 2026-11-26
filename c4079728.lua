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
-- 初始化卡片效果，注册卡名记述、超量召唤手续与苏生限制，以及特召「护宝炮妖船长 尾宿五」的①效果与检索或特召指定字段怪兽的②效果
function s.initial_effect(c)
	-- 记录此卡文本上记述了「护宝炮妖船长 尾宿五」和「阿不思的落胤」卡名
	aux.AddCodeList(c,29601381,68468459)
	-- 注册超量召唤手续，需要4星「护宝炮妖」怪兽2只以上作为超量素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x155),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 4星「护宝炮妖」怪兽×2只以上 这个卡名的①②的效果1回合只能有1次使用其中任意1个。 ①：这张卡超量召唤的场合或者被送去墓地的场合才能发动。从自己的卡组·墓地把1只「护宝炮妖船长 尾宿五」特殊召唤。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。 ②：把这张卡2个超量素材取除才能发动。从卡组选以下怪兽之内1只加入手卡或特殊召唤。 ●「护宝炮妖」怪兽 ●「兽带斗神」怪兽 ●「阿不思的落胤」或者有那个卡名记述的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 发动条件检查，确认这张卡是以超量召唤方式出场的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数，检查是否为卡号29601381（「护宝炮妖船长 尾宿五」）且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCode(29601381) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查自己怪兽区是否有空位且卡组·墓地存在「护宝炮妖船长 尾宿五」，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组·墓地是否存在至少1只可特殊召唤的「护宝炮妖船长 尾宿五」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置从自己卡组·墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理，确认空位后从自己卡组·墓地选1只「护宝炮妖船长 尾宿五」特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空位则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示控制者选择要特殊召唤的「护宝炮妖船长 尾宿五」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组·墓地（受王家长眠之谷限制过滤）选择1只「护宝炮妖船长 尾宿五」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「护宝炮妖船长 尾宿五」表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动代价处理，检查并取除这张卡的2个超量素材
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤函数，检查是否为「护宝炮妖」、「兽带斗神」或「阿不思的落胤」及其记述怪兽，且能加入手卡或在有空位时可特殊召唤
function s.spfilter2(c,e,tp)
	-- 判断卡片是否为「护宝炮妖」怪兽、「兽带斗神」怪兽或「阿不思的落胤」及其卡名记述怪兽
	if not ((c:IsSetCard(0x155,0x179) or aux.IsCodeOrListed(c,68468459)) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动条件检查，确认自己卡组存在至少1只符合条件的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只满足加入手卡或特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果处理，从卡组选1只符合条件的怪兽加入手卡或表侧表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者从卡组选择要加入手卡或特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取当前自己怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断选中的怪兽是否加入手卡（可加手且无法特召、无空位或玩家选择加手时执行）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入自己手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

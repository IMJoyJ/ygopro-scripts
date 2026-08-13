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
-- 初始化函数：为这张卡添加超量召唤手续、苏生限制，并注册①效果（超量召唤或送墓时触发的特殊召唤效果，分为e1和e2两个时机）和②效果（起动效果，取除2个素材检索/特召），①与②通过相同的CountLimit code共用1回合1次次数。
function s.initial_effect(c)
	-- 将「护宝炮妖船长 尾宿五」(29601381)和「阿不思的落胤」(68468459)登记为这张卡记述的卡名，供“有那个卡名记述的怪兽”的判定使用。
	aux.AddCodeList(c,29601381,68468459)
	-- 设置超量召唤手续：以2只以上等级4的「护宝炮妖」怪兽为素材进行超量召唤，最多可叠放99只（即不限制上限）。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x155),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①效果：这张卡超量召唤的场合或者被送去墓地的场合才能发动。从自己的卡组·墓地把1只「护宝炮妖船长 尾宿五」特殊召唤。
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
	-- ②效果：把这张卡2个超量素材取除才能发动。从卡组选以下怪兽之内1只加入手卡或特殊召唤。●「护宝炮妖」怪兽 ●「兽带斗神」怪兽 ●「阿不思的落胤」或者有那个卡名记述的怪兽
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
-- e2的发动条件：这张卡是以超量召唤方式成功召唤的（对应①效果中的“超量召唤的场合”）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果选择对象的过滤条件：卡号是29601381的「护宝炮妖船长 尾宿五」，且能够被这个效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(29601381) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检查：自己主要怪兽区有空位，并且卡组或墓地中存在符合条件的「护宝炮妖船长 尾宿五」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可以特殊召唤的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组·墓地中是否存在1张以上满足s.spfilter的「护宝炮妖船长 尾宿五」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁效果涉及特殊召唤，预定从卡组·墓地处理1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：若主怪兽区没有空位则不处理；否则选择1张满足条件且不受王家长眠之谷影响的「护宝炮妖船长 尾宿五」，将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果没有可用的主怪兽区空格，则无法进行特殊召唤，效果处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组·墓地中选出1张满足s.spfilter、并且不受王家长眠之谷影响的「护宝炮妖船长 尾宿五」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：检查这张卡是否有2个超量素材，并取除2个作为代价。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ②效果的选择对象过滤：必须是「护宝炮妖」或「兽带斗神」怪兽，或者是「阿不思的落胤」或记述了该卡名的怪兽；同时要是怪兽卡，并且能够加入手卡或能够被特殊召唤。
function s.spfilter2(c,e,tp)
	-- 先排除不属于上述字段/卡名记述范围或不是怪兽卡的卡。
	if not ((c:IsSetCard(0x155,0x179) or aux.IsCodeOrListed(c,68468459)) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己主要怪兽区的空格数，用于判断该卡能否被特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的发动检查：卡组中存在1张以上满足s.spfilter2的怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中存在满足②效果可选条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ②效果处理：从卡组选择1张符合条件的怪兽；优先依据玩家选择或能否特召来决定加入手卡或特殊召唤：若可以加入手卡且（不能特召/无空位/玩家选加入手卡）则加入手卡；否则在有空位且能特召时特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要操作的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己的卡组中选择1张满足s.spfilter2条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取自己主要怪兽区的空格数，用于特召分支的判定。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 如果该卡可以加入手卡，并且（不能特殊召唤，或没有特召空格，或玩家选择加入手卡）则执行加入手卡的处理。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 若满足特殊召唤条件且有空格，则将选中的卡以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--華麗なるハーピィ・レディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己场上1只「鹰身女郎三姐妹」回到持有者卡组。那之后，可以把3只原本卡名不同的「鹰身」怪兽从自己的手卡·卡组·墓地各选1只特殊召唤。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
-- ②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合发动。从卡组把1只「鹰身」怪兽加入手卡。
function c65664792.initial_effect(c)
	-- 注册卡片记有「鹰身女郎三姐妹」的卡片密码信息
	aux.AddCodeList(c,12206212)
	-- ①：选自己场上1只「鹰身女郎三姐妹」回到持有者卡组。那之后，可以把3只原本卡名不同的「鹰身」怪兽从自己的手卡·卡组·墓地各选1只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65664792)
	e1:SetTarget(c65664792.target)
	e1:SetOperation(c65664792.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合发动。从卡组把1只「鹰身」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,65664793)
	e2:SetCondition(c65664792.thcon)
	e2:SetTarget(c65664792.thtg)
	e2:SetOperation(c65664792.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上可以返回卡组的「鹰身女郎三姐妹」
function c65664792.tdfilter(c)
	return c:IsCode(12206212) and c:IsAbleToDeck()
end
-- 过滤可以特殊召唤的「鹰身」怪兽
function c65664792.spfilter(c,e,tp)
	return c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤手卡中可以特殊召唤的「鹰身」怪兽，且卡组和墓地中存在与其原本卡名不同、可特殊召唤的「鹰身」怪兽
function c65664792.spfilter1(c,e,tp)
	return c65664792.spfilter(c,e,tp)
		-- 检查卡组中是否存在与手卡选择的怪兽原本卡名不同、且可特殊召唤的「鹰身」怪兽
		and Duel.IsExistingMatchingCard(c65664792.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤卡组中与手卡选择的怪兽原本卡名不同、且可特殊召唤的「鹰身」怪兽，且墓地中存在与前两者原本卡名都不同、可特殊召唤的「鹰身」怪兽
function c65664792.spfilter2(c,e,tp,c1)
	return c65664792.spfilter(c,e,tp)
		and not c:IsOriginalCodeRule(c1:GetOriginalCodeRule())
		-- 检查墓地中是否存在与手卡、卡组选择的怪兽原本卡名都不同、且可特殊召唤的「鹰身」怪兽
		and Duel.IsExistingMatchingCard(c65664792.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp,c1,c)
end
-- 过滤墓地中与手卡、卡组选择的怪兽原本卡名都不同、且可特殊召唤的「鹰身」怪兽
function c65664792.spfilter3(c,e,tp,c1,c2)
	return c65664792.spfilter(c,e,tp)
		and not c:IsOriginalCodeRule(c1:GetOriginalCodeRule())
		and not c:IsOriginalCodeRule(c2:GetOriginalCodeRule())
end
-- ①号效果的发动准备与合法性检测
function c65664792.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以返回卡组的「鹰身女郎三姐妹」
	if chk==0 then return Duel.IsExistingMatchingCard(c65664792.tdfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 设置连锁处理的操作信息，为将场上的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
-- ①号效果的处理函数
function c65664792.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己场上1只「鹰身女郎三姐妹」
	local dg=Duel.SelectMatchingCard(tp,c65664792.tdfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的怪兽送回持有者卡组并洗牌，若成功则继续处理
	if #dg>0 and Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查手卡中是否存在满足特殊召唤条件的「鹰身」怪兽
		and Duel.IsExistingMatchingCard(c65664792.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(65664792,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡选择1只「鹰身」怪兽
		local sg1=Duel.SelectMatchingCard(tp,c65664792.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只与手卡选择的怪兽原本卡名不同的「鹰身」怪兽
		local sg2=Duel.SelectMatchingCard(tp,c65664792.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,sg1:GetFirst())
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从墓地选择1只与前两者原本卡名都不同的「鹰身」怪兽
		local sg3=Duel.SelectMatchingCard(tp,c65664792.spfilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,sg1:GetFirst(),sg2:GetFirst())
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		-- 中断当前效果，使后续的特殊召唤处理与返回卡组不视为同时处理
		Duel.BreakEffect()
		-- 将选中的3只「鹰身」怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合发动。从卡组把1只「鹰身」怪兽加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c65664792.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册风属性特殊召唤限制的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制只能特殊召唤风属性怪兽
function c65664792.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 检查是否是场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏
function c65664792.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and (rp==1-tp or (rp==tp and re:GetHandler():IsSetCard(0x64))) and c:IsPreviousControler(tp)
end
-- 过滤卡组中可以加入手卡的「鹰身」怪兽
function c65664792.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x64) and c:IsAbleToHand()
end
-- ②号效果的发动准备与合法性检测
function c65664792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息，为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理函数
function c65664792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只「鹰身」怪兽
	local g=Duel.SelectMatchingCard(tp,c65664792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

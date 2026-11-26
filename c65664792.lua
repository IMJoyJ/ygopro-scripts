--華麗なるハーピィ・レディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己场上1只「鹰身女郎三姐妹」回到持有者卡组。那之后，可以把3只原本卡名不同的「鹰身」怪兽从自己的手卡·卡组·墓地各选1只特殊召唤。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
-- ②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合发动。从卡组把1只「鹰身」怪兽加入手卡。
function c65664792.initial_effect(c)
	-- 记录此卡效果文本中记述有「鹰身女郎三姐妹」的卡名
	aux.AddCodeList(c,12206212)
	-- 这个卡名的①②的效果1回合各能使用1次。①：选自己场上1只「鹰身女郎三姐妹」回到持有者卡组。那之后，可以把3只原本卡名不同的「鹰身」怪兽从自己的手卡·卡组·墓地各选1只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65664792)
	e1:SetTarget(c65664792.target)
	e1:SetOperation(c65664792.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合发动。从卡组把1只「鹰身」怪兽加入手卡。
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
-- 过滤卡名为「鹰身女郎三姐妹」且可返回卡组的怪兽
function c65664792.tdfilter(c)
	return c:IsCode(12206212) and c:IsAbleToDeck()
end
-- 过滤可特殊召唤的「鹰身」怪兽
function c65664792.spfilter(c,e,tp)
	return c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤手卡中可特召的「鹰身」怪兽，并要求卡组和墓地能凑齐另外2只原本卡名互不相同的「鹰身」怪兽
function c65664792.spfilter1(c,e,tp)
	return c65664792.spfilter(c,e,tp)
		-- 检查卡组中是否存在原本卡名不同于c、且能在墓地找到第3只不同原本卡名「鹰身」怪兽的「鹰身」怪兽
		and Duel.IsExistingMatchingCard(c65664792.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤卡组中原本卡名不同于手卡所选怪兽c1、且墓地存在第3只不同原本卡名可特召「鹰身」怪兽的卡
function c65664792.spfilter2(c,e,tp,c1)
	return c65664792.spfilter(c,e,tp)
		and not c:IsOriginalCodeRule(c1:GetOriginalCodeRule())
		-- 检查墓地中是否存在原本卡名与c1及c均不相同的可特召「鹰身」怪兽
		and Duel.IsExistingMatchingCard(c65664792.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp,c1,c)
end
-- 过滤墓地中原本卡名同时不同于c1和c2的可特召「鹰身」怪兽
function c65664792.spfilter3(c,e,tp,c1,c2)
	return c65664792.spfilter(c,e,tp)
		and not c:IsOriginalCodeRule(c1:GetOriginalCodeRule())
		and not c:IsOriginalCodeRule(c2:GetOriginalCodeRule())
end
-- 发动前确认己方场上存在可回卡组的「鹰身女郎三姐妹」，并登记返回卡组的操作信息
function c65664792.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在至少1只可返回卡组的「鹰身女郎三姐妹」
	if chk==0 then return Duel.IsExistingMatchingCard(c65664792.tdfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 登记将己方怪兽区1张卡返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
-- ①效果处理：选己方场上1只「鹰身女郎三姐妹」回卡组，若回卡组成功且场上至少有3个空位（且未受「青眼精灵龙」限制），可从手卡·卡组·墓地各特召1只原本卡名不同的「鹰身」怪兽
function c65664792.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送选择要返回卡组的「鹰身女郎三姐妹」的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让己方从己方场上选择1只「鹰身女郎三姐妹」
	local dg=Duel.SelectMatchingCard(tp,c65664792.tdfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的「鹰身女郎三姐妹」以效果洗回持有者卡组并判断是否回卡组成功
	if #dg>0 and Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查手卡是否存在能与卡组·墓地凑齐3只不同原本卡名「鹰身」怪兽的起点怪兽
		and Duel.IsExistingMatchingCard(c65664792.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问己方玩家是否从手卡·卡组·墓地各特殊召唤1只原本卡名不同的「鹰身」怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(65664792,2)) then  --"是否特殊召唤？"
		-- 向己方发送从手卡选择要特殊召唤的「鹰身」怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从手卡选择第1只符合条件的「鹰身」怪兽
		local sg1=Duel.SelectMatchingCard(tp,c65664792.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 向己方发送从卡组选择要特殊召唤的「鹰身」怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从卡组选择第2只原本卡名不同于手卡所选怪兽的「鹰身」怪兽
		local sg2=Duel.SelectMatchingCard(tp,c65664792.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,sg1:GetFirst())
		-- 向己方发送从墓地选择要特殊召唤的「鹰身」怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从墓地选择第3只原本卡名与前两只均不相同的「鹰身」怪兽
		local sg3=Duel.SelectMatchingCard(tp,c65664792.spfilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,sg1:GetFirst(),sg2:GetFirst())
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		-- 插入效果处理间断，使「鹰身女郎三姐妹」回卡组与后续3只特召视为不同时处理
		Duel.BreakEffect()
		-- 将合并后的3只「鹰身」怪兽同时以表侧表示特殊召唤到己方场上
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
		-- 为己方玩家注册持续至回合结束的特殊召唤属性自肃效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件函数：阻止特殊召唤风属性以外的怪兽
function c65664792.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 检查②效果发动条件：此卡在己方场上被对方的效果或己方「鹰身」卡的效果破坏
function c65664792.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and (rp==1-tp or (rp==tp and re:GetHandler():IsSetCard(0x64))) and c:IsPreviousControler(tp)
end
-- 过滤卡组中可加入手卡的「鹰身」怪兽
function c65664792.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x64) and c:IsAbleToHand()
end
-- 发动前登记从己方卡组将1只「鹰身」怪兽加入手卡的操作信息
function c65664792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记从己方卡组把1只怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从己方卡组选择1只「鹰身」怪兽加入手卡并向对方确认
function c65664792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送从卡组选择要加入手卡的「鹰身」怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从卡组选择1只「鹰身」怪兽
	local g=Duel.SelectMatchingCard(tp,c65664792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的「鹰身」怪兽以效果加入己方手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的「鹰身」怪兽进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end

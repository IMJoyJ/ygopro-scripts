--青き眼の巫女
-- 效果：
-- 「青色眼睛的巫女」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上的表侧表示的这张卡成为效果的对象时才能发动。选自己场上1只效果怪兽送去墓地，从卡组把最多2只「青眼」怪兽加入手卡（同名卡最多1张）。
-- ②：这张卡在墓地存在的场合，以自己场上1只「青眼」怪兽为对象才能发动。那只怪兽回到持有者卡组，这张卡从墓地特殊召唤。
function c36734924.initial_effect(c)
	-- 「青色眼睛的巫女」的①②的效果1回合只能有1次使用其中任意1个。①：场上的表侧表示的这张卡成为效果的对象时才能发动。选自己场上1只效果怪兽送去墓地，从卡组把最多2只「青眼」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36734924,0))  --"把最多2只「青眼」怪兽加入手卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCountLimit(1,36734924)
	e1:SetCondition(c36734924.thcon)
	e1:SetTarget(c36734924.thtg)
	e1:SetOperation(c36734924.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只「青眼」怪兽为对象才能发动。那只怪兽回到持有者卡组，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36734924,1))  --"这张卡从墓地特殊召唤"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36734924)
	e2:SetTarget(c36734924.sptg)
	e2:SetOperation(c36734924.spop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：成为效果对象的卡中包含自身
function c36734924.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 过滤场上表侧表示、可送去墓地的效果怪兽
function c36734924.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
-- 过滤卡组中可加入手牌的「青眼」怪兽
function c36734924.thfilter(c)
	return c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动目标检查
function c36734924.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可送去墓地的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36734924.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在可检索的「青眼」怪兽
		and Duel.IsExistingMatchingCard(c36734924.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将自己场上1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：从卡组把卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：送墓自己场上1只效果怪兽，检索最多2只卡名不同的「青眼」怪兽
function c36734924.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只表侧表示效果怪兽
	local tg=Duel.SelectMatchingCard(tp,c36734924.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	-- 将选中的怪兽送去墓地，并确认成功送入墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取卡组中所有满足条件的「青眼」怪兽
		local g=Duel.GetMatchingGroup(c36734924.thfilter,tp,LOCATION_DECK,0,nil)
		if g:GetCount()<=0 then return end
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选最多2只卡名不同的「青眼」怪兽
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,sg1)
	end
end
-- 过滤场上表侧表示、可返回卡组的「青眼」怪兽
function c36734924.spfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0xdd) and c:IsAbleToDeck() and (ft>0 or c:GetSequence()<5)
end
-- 效果发动取对象及合法性检查
function c36734924.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己主要怪兽区域的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36734924.spfilter(chkc,ft) end
	-- 检查场上是否存在可返回卡组的目标「青眼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c36734924.spfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		and ft>-1 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只「青眼」怪兽作为对象
	local g=Duel.SelectTarget(tp,c36734924.spfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置操作信息：将选中的对象卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：对象怪兽返回卡组，自身从墓地特殊召唤
function c36734924.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽洗回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将自身从墓地表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

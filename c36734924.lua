--青き眼の巫女
-- 效果：
-- 「青色眼睛的巫女」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上的表侧表示的这张卡成为效果的对象时才能发动。选自己场上1只效果怪兽送去墓地，从卡组把最多2只「青眼」怪兽加入手卡（同名卡最多1张）。
-- ②：这张卡在墓地存在的场合，以自己场上1只「青眼」怪兽为对象才能发动。那只怪兽回到持有者卡组，这张卡从墓地特殊召唤。
function c36734924.initial_effect(c)
	-- 「青色眼睛的巫女」的①效果：场上的表侧表示的这张卡成为效果的对象时才能发动。选自己场上1只效果怪兽送去墓地，从卡组把最多2只「青眼」怪兽加入手卡（同名卡最多1张）。
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
	-- 「青色眼睛的巫女」的②效果：这张卡在墓地存在的场合，以自己场上1只「青眼」怪兽为对象才能发动。那只怪兽回到持有者卡组，这张卡从墓地特殊召唤。
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
-- ①效果的发动条件：判断成为效果对象的卡中是否包含本卡，即本卡成为效果的对象时才满足发动条件。
function c36734924.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 用于选择送去墓地的怪兽的过滤器：必须是表侧表示的效果怪兽，并且可以被送去墓地。
function c36734924.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
-- 用于检索卡组的过滤器：必须是「青眼」字段的怪兽卡，并且可以加入手卡。
function c36734924.thfilter(c)
	return c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动合法性检查：自己场上存在可送去墓地的效果怪兽，且卡组存在可加入手卡的「青眼」怪兽，同时设置操作信息。
function c36734924.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在1只以上满足送去墓地条件的表侧效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36734924.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组是否存在1只以上满足加入手卡条件的「青眼」怪兽。
		and Duel.IsExistingMatchingCard(c36734924.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：宣告要处理“送去墓地”分类，预计将自己场上的1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
	-- 设置本次连锁的操作信息：宣告要处理“加入手卡”分类，预计从卡组将1只（实际最多2只）「青眼」怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：选择自己场上1只效果怪兽送去墓地；若成功送墓，则从卡组选出1～2张卡名不同的「青眼」怪兽加入手卡，并让对方确认。
function c36734924.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只满足条件的表侧效果怪兽。
	local tg=Duel.SelectMatchingCard(tp,c36734924.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	-- 判断所选怪兽是否确实因效果被送去墓地且仍位于墓地，若是则继续执行检索部分。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 取得卡组中所有满足检索条件的「青眼」怪兽作为候选集合。
		local g=Duel.GetMatchingGroup(c36734924.thfilter,tp,LOCATION_DECK,0,nil)
		if g:GetCount()<=0 then return end
		-- 向玩家弹出提示：请选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 在候选集合中让玩家选择1～2张卡名互不相同的「青眼」怪兽。
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		-- 将选出的「青眼」怪兽加入其持有者的手卡。
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg1)
	end
end
-- ②效果选择对象的过滤器：必须是表侧表示的「青眼」怪兽，可以返回卡组；且当自己场上没有可用空格时，只能选择主要怪兽区的怪兽，以便弹回后腾出位置用于特殊召唤。
function c36734924.spfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0xdd) and c:IsAbleToDeck() and (ft>0 or c:GetSequence()<5)
end
-- ②效果的发动处理：计算可用的主要怪兽区数量；选择对象阶段校验对象是否合法；发动合法性检查确认存在可选对象、有足够区域且本卡可以特殊召唤。
function c36734924.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家tp的主要怪兽区可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36734924.spfilter(chkc,ft) end
	-- 检查自己场上是否存在1只以上满足条件的「青眼」怪兽可选，并且本卡满足特殊召唤条件。
	if chk==0 then return Duel.IsExistingTarget(c36734924.spfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		and ft>-1 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家弹出提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上选择1只「青眼」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c36734924.spfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置操作信息：将选中的对象卡返回持有者卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：将本卡从墓地特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：获得对象卡；若对象仍与效果关联且成功返回卡组，且本卡仍与效果关联，则将本卡从墓地特殊召唤。
function c36734924.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象仍与此效果关联、能成功返回卡组，且本卡未被无效或失去关联，满足条件才继续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将本卡以表侧表示特殊召唤到其控制者tp的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

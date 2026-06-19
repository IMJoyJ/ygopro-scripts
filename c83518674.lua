--未界域のオゴポゴ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的奥古布古」以外的场合，再从手卡把1只「未界域的奥古布古」特殊召唤，自己从卡组抽1张。
-- ②：这张卡从手卡丢弃的场合才能发动。从卡组把「未界域的奥古布古」以外的1张「未界域」卡送去墓地。
function c83518674.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的奥古布古」以外的场合，再从手卡把1只「未界域的奥古布古」特殊召唤，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c83518674.spcost)
	e1:SetTarget(c83518674.sptg)
	e1:SetOperation(c83518674.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合才能发动。从卡组把「未界域的奥古布古」以外的1张「未界域」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,83518674)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c83518674.tgtg)
	e2:SetOperation(c83518674.tgop)
	c:RegisterEffect(e2)
end
-- 用于检测手卡中的这张卡是否未公开，作为发动①效果的Cost
function c83518674.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手卡中可以特殊召唤的「未界域的奥古布古」
function c83518674.spfilter(c,e,tp)
	return c:IsCode(83518674) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备，检查手卡中是否有可丢弃的卡，并设置丢弃手卡的操作信息
function c83518674.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以因效果丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①效果的效果处理：由对方随机选1张手卡丢弃，若丢弃的不是「未界域的奥古布古」，则可以从手卡特殊召唤1只「未界域的奥古布古」并抽1张卡
function c83518674.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的全部手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()<=0 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 将选中的手卡丢弃，并判断丢弃的卡是否不是「未界域的奥古布古」
	if Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(83518674)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取手卡中所有可以特殊召唤的「未界域的奥古布古」
		local spg=Duel.GetMatchingGroup(c83518674.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续的特殊召唤和抽卡不与丢弃手卡视为同时处理
		Duel.BreakEffect()
		-- 将选中的怪兽特殊召唤，并判断是否特殊召唤成功
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤卡组中「未界域的奥古布古」以外的「未界域」卡
function c83518674.tgfilter(c)
	return c:IsSetCard(0x11e) and c:IsAbleToGrave() and not c:IsCode(83518674)
end
-- ②效果的发动准备，检查卡组中是否有符合条件的卡，并设置送去墓地的操作信息
function c83518674.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「未界域的奥古布古」以外的「未界域」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c83518674.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组将1张「未界域的奥古布古」以外的「未界域」卡送去墓地
function c83518674.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张「未界域的奥古布古」以外的「未界域」卡
	local g=Duel.SelectMatchingCard(tp,c83518674.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

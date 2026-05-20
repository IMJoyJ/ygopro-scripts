--未界域のネッシー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的尼斯水怪」以外的场合，再从手卡把1只「未界域的尼斯水怪」特殊召唤，自己抽1张。
-- ②：这张卡从手卡丢弃的场合才能发动。从卡组把「未界域的尼斯水怪」以外的1张「未界域」卡加入手卡。
function c70711847.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的尼斯水怪」以外的场合，再从手卡把1只「未界域的尼斯水怪」特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70711847,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c70711847.spcost)
	e1:SetTarget(c70711847.sptg)
	e1:SetOperation(c70711847.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从手卡丢弃的场合才能发动。从卡组把「未界域的尼斯水怪」以外的1张「未界域」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70711847,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,70711847)
	e2:SetTarget(c70711847.thtg)
	e2:SetOperation(c70711847.thop)
	c:RegisterEffect(e2)
end
-- 检查自身是否未公开，作为展示手卡发动效果的Cost
function c70711847.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：过滤出可以特殊召唤的「未界域的尼斯水怪」
function c70711847.spfilter(c,e,tp)
	return c:IsCode(70711847) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备，检查手卡是否有可丢弃的卡，并设置丢弃手卡的操作信息
function c70711847.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以因效果丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置当前连锁的操作信息为：丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的处理：由对方随机选1张手卡丢弃，若丢弃的不是「未界域的尼斯水怪」，则特殊召唤1只「未界域的尼斯水怪」并抽1张卡
function c70711847.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的所有手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()<=0 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 成功丢弃随机选出的卡，且该卡不是「未界域的尼斯水怪」
	if tc and Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(70711847)
		-- 并且自身场上有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取手卡中所有满足特殊召唤条件的「未界域的尼斯水怪」
		local spg=Duel.GetMatchingGroup(c70711847.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续的特殊召唤和抽卡与丢弃手卡不视为同时处理
		Duel.BreakEffect()
		-- 将选中的「未界域的尼斯水怪」特殊召唤，若特殊召唤成功
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤函数：过滤出「未界域的尼斯水怪」以外且可以加入手卡的「未界域」卡片
function c70711847.thfilter(c)
	return c:IsSetCard(0x11e) and not c:IsCode(70711847) and c:IsAbleToHand()
end
-- 效果②的发动准备，检查卡组是否存在可检索的卡，并设置检索卡片的操作信息
function c70711847.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「未界域」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70711847.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1张「未界域的尼斯水怪」以外的「未界域」卡加入手卡，并给对方确认
function c70711847.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「未界域」卡
	local g=Duel.SelectMatchingCard(tp,c70711847.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

--未界域のジャッカロープ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的鹿角兔」以外的场合，再从手卡把1只「未界域的鹿角兔」特殊召唤，自己从卡组抽1张。
-- ②：这张卡从手卡丢弃的场合才能发动。从卡组把「未界域的鹿角兔」以外的1只「未界域」怪兽守备表示特殊召唤。
function c43694650.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的鹿角兔」以外的场合，再从手卡把1只「未界域的鹿角兔」特殊召唤，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43694650,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c43694650.spcost)
	e1:SetTarget(c43694650.sptg)
	e1:SetOperation(c43694650.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合才能发动。从卡组把「未界域的鹿角兔」以外的1只「未界域」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43694650,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,43694650)
	e2:SetTarget(c43694650.sptg2)
	e2:SetOperation(c43694650.spop2)
	c:RegisterEffect(e2)
end
-- 检查是否公开手卡
function c43694650.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手卡中可以特殊召唤的「未界域的鹿角兔」
function c43694650.spfilter(c,e,tp)
	return c:IsCode(43694650) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时需要丢弃手卡
function c43694650.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置丢弃手卡的效果信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 处理①效果的主要流程：随机选择对方手卡并丢弃，若非「未界域的鹿角兔」则特殊召唤并抽卡
function c43694650.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()<=0 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 将选中的卡送去墓地并判断是否非「未界域的鹿角兔」
	if Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(43694650)
		-- 检查场上是否有特殊召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取手卡中符合条件的「未界域的鹿角兔」
		local spg=Duel.GetMatchingGroup(c43694650.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将选中的「未界域的鹿角兔」特殊召唤
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 从卡组抽一张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤卡组中符合条件的「未界域」怪兽
function c43694650.spfilter2(c,e,tp)
	return c:IsSetCard(0x11e) and not c:IsCode(43694650) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置②效果的发动条件
function c43694650.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「未界域」怪兽
		and Duel.IsExistingMatchingCard(c43694650.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的效果信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果的主要流程：从卡组选择符合条件的「未界域」怪兽守备表示特殊召唤
function c43694650.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中符合条件的「未界域」怪兽
	local g=Duel.SelectMatchingCard(tp,c43694650.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「未界域」怪兽守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

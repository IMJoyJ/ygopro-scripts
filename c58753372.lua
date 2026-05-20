--超量妖精アルファン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以自己场上1只「超级量子」怪兽为对象才能发动。自己场上的全部怪兽的等级变成和作为对象的怪兽相同。
-- ②：把这张卡解放才能发动。从卡组把3只卡名不同的「超级量子」怪兽给对方观看，对方从那之中随机选1只。那1只在自己场上特殊召唤，剩余送去墓地。
function c58753372.initial_effect(c)
	-- ①：1回合1次，以自己场上1只「超级量子」怪兽为对象才能发动。自己场上的全部怪兽的等级变成和作为对象的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58753372,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c58753372.target)
	e1:SetOperation(c58753372.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡解放才能发动。从卡组把3只卡名不同的「超级量子」怪兽给对方观看，对方从那之中随机选1只。那1只在自己场上特殊召唤，剩余送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58753372,1))  --"解放"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,58753372)
	e2:SetCost(c58753372.spcost)
	e2:SetTarget(c58753372.sptg)
	e2:SetOperation(c58753372.spop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且等级大于0的怪兽
function c58753372.filter1(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 过滤自己场上表侧表示、等级大于0的「超级量子」怪兽，且场上还存在至少1只其他表侧表示且等级大于0的怪兽
function c58753372.filter2(c,tp)
	return c58753372.filter1(c) and c:IsSetCard(0xdc)
		-- 检查自己场上是否存在除该卡以外的、表侧表示且等级大于0的怪兽
		and Duel.IsExistingMatchingCard(c58753372.filter1,tp,LOCATION_MZONE,0,1,c)
end
-- 效果①的发动准备，检查场上是否存在符合条件的「超级量子」怪兽以及是否存在不同等级的怪兽，并选择1只「超级量子」怪兽作为对象
function c58753372.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有表侧表示且等级大于0的怪兽
	local g1=Duel.GetMatchingGroup(c58753372.filter1,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c58753372.filter2(chkc,tp) end
	-- 检查是否存在可作为对象的「超级量子」怪兽，且场上怪兽的等级不全相同
	if chk==0 then return Duel.IsExistingTarget(c58753372.filter2,tp,LOCATION_MZONE,0,1,nil,tp) and g1:GetClassCount(Card.GetLevel)>1 end
	-- 提示玩家选择要作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「超级量子」怪兽作为对象
	Duel.SelectTarget(tp,c58753372.filter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果①的效果处理，将自己场上除作为对象的怪兽以外的所有表侧表示怪兽的等级变成和作为对象的怪兽相同
function c58753372.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取自己场上除作为对象的怪兽以外的所有表侧表示且等级大于0的怪兽
		local g=Duel.GetMatchingGroup(c58753372.filter1,tp,LOCATION_MZONE,0,tc)
		local lc=g:GetFirst()
		local lv=tc:GetLevel()
		while lc do
			-- 自己场上的全部怪兽的等级变成和作为对象的怪兽相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
			lc=g:GetNext()
		end
	end
end
-- 效果②的发动代价，将这张卡解放
function c58753372.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「超级量子」怪兽
function c58753372.spfilter1(c,e,tp)
	return c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备，检查卡组中是否至少有3种卡名不同的「超级量子」怪兽，并设置特殊召唤的操作信息
function c58753372.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否能将卡组的卡送去墓地
		if not Duel.IsPlayerCanDiscardDeck(tp,1) then return false end
		-- 获取卡组中所有可以特殊召唤的「超级量子」怪兽
		local g=Duel.GetMatchingGroup(c58753372.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=3
	end
	-- 设置效果处理信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果②的效果处理，从卡组选3只卡名不同的「超级量子」怪兽给对方观看，对方随机选1只特殊召唤，其余送去墓地
function c58753372.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查玩家是否能将卡组的卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 效果处理时，获取卡组中所有可以特殊召唤的「超级量子」怪兽
	local g=Duel.GetMatchingGroup(c58753372.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从符合条件的怪兽中选择3只卡名不同的怪兽
		local cg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选出的3只怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,cg)
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		-- 提示对方玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=cg:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将对方选中的那1只怪兽在自己场上特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			cg:RemoveCard(tc)
		end
		-- 将剩余未被选中的怪兽送去墓地
		Duel.SendtoGrave(cg,REASON_EFFECT)
	end
end

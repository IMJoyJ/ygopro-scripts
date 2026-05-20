--古衛兵アギド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组有卡被送去对方墓地的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地选「古卫兵 阿基多」以外的1只天使族·地属性·4星怪兽特殊召唤。
-- ②：这张卡从手卡·卡组送去墓地的场合才能发动。从双方卡组上面把5张卡送去墓地。那之后，自己墓地有「现世与冥界的逆转」存在的场合，可以从自己或者对方的卡组上面把5张卡送去墓地。
function c62320425.initial_effect(c)
	-- 注册「现世与冥界的逆转」的卡片密码，表示该卡的效果中记有该卡名
	aux.AddCodeList(c,17484499)
	-- ①：从手卡·卡组有卡被送去对方墓地的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地选「古卫兵 阿基多」以外的1只天使族·地属性·4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62320425,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,62320425)
	e1:SetCondition(c62320425.spcon)
	e1:SetTarget(c62320425.sptg)
	e1:SetOperation(c62320425.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组送去墓地的场合才能发动。从双方卡组上面把5张卡送去墓地。那之后，自己墓地有「现世与冥界的逆转」存在的场合，可以从自己或者对方的卡组上面把5张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62320425,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,62320426)
	e2:SetCondition(c62320425.discon)
	e2:SetTarget(c62320425.distg)
	e2:SetOperation(c62320425.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片是否从手卡或卡组送去对方的墓地
function c62320425.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and c:IsControler(1-tp)
end
-- 效果①的发动条件：检查是否有卡从手卡或卡组送去对方的墓地
function c62320425.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62320425.cfilter,1,nil,tp)
end
-- 效果①的靶指向/发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c62320425.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：用于从墓地特殊召唤「古卫兵 阿基多」以外的1只地属性·天使族·4星怪兽
function c62320425.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(4) and not c:IsCode(62320425)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理：将自身特殊召唤，之后可选择是否从自己墓地特殊召唤1只满足条件的怪兽
function c62320425.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，并成功将这张卡从手卡特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查自己场上是否还有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己墓地中满足条件且不受「王家长眠之谷」影响的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c62320425.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 如果存在满足条件的怪兽，则询问玩家是否选择特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(62320425,2)) then  --"是否从墓地选怪兽特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理与前面的特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的发动条件：检查这张卡是否是从手卡或卡组送去墓地
function c62320425.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的靶指向/发动准备：检查双方是否能将卡组顶端的卡送去墓地，并设置送墓的操作信息
function c62320425.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都能将卡组顶端的5张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	-- 设置卡组送墓的操作信息，表示双方卡组顶端各有5张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,5)
end
-- 效果②的处理：将双方卡组顶端5张卡送去墓地，若自己墓地有「现世与冥界的逆转」存在，可再选择让其中一方卡组顶端5张卡送去墓地
function c62320425.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的5张卡
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方卡组最上方的5张卡
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁用接下来的洗牌检测，防止在送墓处理中产生不必要的洗牌
	Duel.DisableShuffleCheck()
	-- 将双方卡组顶端的卡送去墓地，并检查是否有卡成功送去墓地
	if Duel.SendtoGrave(g1,REASON_EFFECT)~=0 and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 检查自己墓地是否存在「现世与冥界的逆转」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) then
		local off=1
		local ops={}
		local opval={}
		-- 检查自己是否能将卡组顶端的5张卡送去墓地
		if Duel.IsPlayerCanDiscardDeck(tp,5) then
			ops[off]=aux.Stringid(62320425,4)  --"自己卡组5张卡送去墓地"
			opval[off-1]=tp
			off=off+1
		end
		-- 检查对方是否能将卡组顶端的5张卡送去墓地
		if Duel.IsPlayerCanDiscardDeck(1-tp,5) then
			ops[off]=aux.Stringid(62320425,5)  --"对方卡组5张卡送去墓地"
			opval[off-1]=1-tp
			off=off+1
		end
		ops[off]=aux.Stringid(62320425,6)  --"什么都不做"
		opval[off-1]=-1
		-- 让玩家选择要执行的操作（自己送墓、对方送墓或什么都不做）
		local op=Duel.SelectOption(tp,table.unpack(ops))
		local sel=opval[op]
		if sel~=-1 then
			-- 中断当前效果，使后续的卡组送墓处理与前面的送墓不视为同时处理
			Duel.BreakEffect()
			-- 将所选玩家的卡组顶端5张卡送去墓地
			Duel.DiscardDeck(sel,5,REASON_EFFECT)
		end
	end
end

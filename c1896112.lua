--次元誘爆
-- 效果：
-- 把自己场上表侧表示存在的1只融合怪兽回到融合卡组才能发动。双方选择从游戏中除外的怪兽最多2只，在各自场上特殊召唤。
function c1896112.initial_effect(c)
	-- 把自己场上表侧表示存在的1只融合怪兽回到融合卡组才能发动。双方选择从游戏中除外的怪兽最多2只，在各自场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1896112.cost)
	e1:SetTarget(c1896112.target)
	e1:SetOperation(c1896112.operation)
	c:RegisterEffect(e1)
end
-- cost用融合怪兽筛选：必须是表侧表示、融合怪兽、可作为代价返回额外卡组；且当主怪兽区无空位时，只能选择位于主要怪兽区的融合怪兽（不选额外怪兽区），以保证cost后腾出主怪兽区空格。
function c1896112.cfilter(c,ft)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtraAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 发动代价处理：检查自己场上存在符合条件的表侧融合怪兽且主怪兽区有空位；之后由玩家选择1只表侧融合怪兽返回额外卡组作为代价。
function c1896112.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区的可用空格数，用于后续cost选择和空格判断。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- cost条件确认：当前主怪兽区空格数不为-1（基本可正常使用），并且存在至少1张满足cfilter条件的融合怪兽可供返回额外卡组。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c1896112.cfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 向自己发出选择提示（请选择要返回卡组的卡片）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己场上表侧表示的融合怪兽中选择1张符合cfilter条件的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c1896112.cfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的融合怪兽放回额外卡组顶端，作为发动cost。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果处理时的特召对象筛选：对象必须是表侧表示且可以被当前玩家通过该效果特殊召唤（遵守召唤条件和苏生限制）。
function c1896112.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件和对象选择：发动条件要求对方主要怪兽区有空位，且双方除外区各存在至少1只可被特殊召唤的表侧怪兽；满足后由双方玩家各自选择自己除外区的怪兽作为对象（自己1～自身上限，对方1～对方上限）。
function c1896112.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件之一：对方主要怪兽区必须至少有1个空格，用于放置之后要特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 发动条件之一：自己的除外区至少存在1只满足c1896112.filter的表侧怪兽可以作为对象。
		and Duel.IsExistingTarget(c1896112.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 发动条件之一：对方除外区也至少存在1只满足筛选条件的表侧怪兽可以作为对象。
		and Duel.IsExistingTarget(c1896112.filter,1-tp,LOCATION_REMOVED,0,1,nil,e,1-tp) end
	-- 获取自己主怪兽区空格数，作为可选择怪兽数量的初始上限。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft1=1 end
	if ft1>2 then ft1=2 end
	-- 向自己提示选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 自己从自己除外区选择1～ft1只满足条件的表侧怪兽，设为效果对象。
	local g1=Duel.SelectTarget(tp,c1896112.filter,tp,LOCATION_REMOVED,0,1,ft1,nil,e,tp)
	-- 获取对方主怪兽区空格数，用于限制对方可选择/特召的怪兽数量。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft2>2 then ft2=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft2=1 end
	-- 向对方玩家提示选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 对方从对方除外区选择1～ft2只满足条件的表侧怪兽，设为效果对象。
	local g2=Duel.SelectTarget(1-tp,c1896112.filter,1-tp,LOCATION_REMOVED,0,1,ft2,nil,e,1-tp)
	g1:Merge(g2)
	-- 登记本次连锁的处理信息：将合并后的对象组标记为特殊召唤操作，数量为对象总数，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,g1:GetCount(),0,0)
end
-- 效果处理：从连锁信息中取出仍相关的对象，按控制者分为自己组和对方组；在各自场上空格足够且不违反青眼精灵龙“双方不能同时特召2只以上怪兽”的限制时，按顺序用SpecialSummonStep将各自对象特殊召唤，最后SpecialSummonComplete完成特殊召唤。
function c1896112.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象卡组，并过滤出仍与当前效果相关的卡（未离场或未解除联系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsControler,nil,1-tp)
	-- 获取自己主怪兽区当前剩余空格数，以判断能否容纳己方要特召的怪兽。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct1=g1:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft1>=ct1 and (ct1==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		local tc=g1:GetFirst()
		while tc do
			-- 将己方组的一只对象怪兽作为特殊召唤的一步，正面表示由自己特殊召唤到自己场上。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc=g1:GetNext()
		end
	end
	-- 获取对方主怪兽区当前剩余空格数，以判断能否容纳对方要特召的怪兽。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local ct2=g2:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft2>=ct2 and (ct2==1 or not Duel.IsPlayerAffectedByEffect(1-tp,59822133)) then
		local tc=g2:GetFirst()
		while tc do
			-- 将对方组的一只对象怪兽作为特殊召唤的一步，正面表示由对方特殊召唤到对方场上。
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
			tc=g2:GetNext()
		end
	end
	-- 宣告本次特殊召唤过程结束，完成所有SpecialSummonStep的整合处理。
	Duel.SpecialSummonComplete()
end

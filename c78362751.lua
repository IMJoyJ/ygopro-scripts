--しらうおの軍貫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有着「舍利军贯」或者有「舍利军贯」在作为超量素材中的超量怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从手卡把「银鱼军贯」以外的1只「军贯」怪兽特殊召唤。那之后，可以从自己的卡组·墓地选「舍利军贯」任意数量用喜欢的顺序在卡组最上面放置。
function c78362751.initial_effect(c)
	-- ①：自己场上有着「舍利军贯」或者有「舍利军贯」在作为超量素材中的超量怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78362751,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,78362751)
	e1:SetCondition(c78362751.spcon)
	e1:SetTarget(c78362751.sptg)
	e1:SetOperation(c78362751.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从手卡把「银鱼军贯」以外的1只「军贯」怪兽特殊召唤。那之后，可以从自己的卡组·墓地选「舍利军贯」任意数量用喜欢的顺序在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78362751,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,78362752)
	e2:SetTarget(c78362751.sptg2)
	e2:SetOperation(c78362751.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「舍利军贯」，或者以「舍利军贯」作为超量素材的超量怪兽
function c78362751.cfilter(c)
	if c:IsFacedown() then return false end
	local oc=c:GetOverlayGroup()
	return c:IsCode(24639891) or c:IsType(TYPE_XYZ) and oc and oc:IsExists(Card.IsCode,1,nil,24639891)
end
-- 效果①的发动条件函数
function c78362751.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「舍利军贯」或以其为素材的超量怪兽
	return Duel.IsExistingMatchingCard(c78362751.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检测函数
function c78362751.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数
function c78362751.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：手卡中「银鱼军贯」以外的可以特殊召唤的「军贯」怪兽
function c78362751.spfilter(c,e,tp)
	return c:IsSetCard(0x166) and not c:IsCode(78362751) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测函数
function c78362751.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的「军贯」怪兽
		and Duel.IsExistingMatchingCard(c78362751.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤手卡怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤条件：可以返回卡组的「舍利军贯」
function c78362751.filter(c)
	return c:IsCode(24639891) and c:IsAbleToDeck()
end
-- 效果②的效果处理函数
function c78362751.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「军贯」怪兽
	local g=Duel.SelectMatchingCard(tp,c78362751.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功特殊召唤选中的怪兽
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己卡组·墓地中不受王家之谷影响的「舍利军贯」
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c78362751.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,nil)
		-- 若存在可选择的卡，询问玩家是否在卡组最上面放置
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(78362751,2)) then  --"是否选「舍利军贯」在卡组最上面放置？"
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local dg=sg:Select(tp,1,#sg,nil)
			-- 中断效果处理，使后续的放置卡组最上方处理不与特殊召唤同时处理
			Duel.BreakEffect()
			local tc=dg:GetFirst()
			while tc do
				if tc:IsLocation(LOCATION_GRAVE) then
					-- 将墓地的「舍利军贯」送回卡组最上方
					Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
				end
				-- 将卡片移动到卡组最上方
				Duel.MoveSequence(tc,SEQ_DECKTOP)
				tc=dg:GetNext()
			end
			-- 让玩家以喜欢的顺序对卡组最上方的这些卡进行排序
			Duel.SortDecktop(tp,tp,#dg)
		end
	end
end

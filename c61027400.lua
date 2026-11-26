--いくらの軍貫
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「舍利军贯」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1只「舍利军贯」加入手卡或特殊召唤。剩下的卡回到卡组。
function c61027400.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，①：自己场上有「舍利军贯」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61027400+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c61027400.sprcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1只「舍利军贯」加入手卡或特殊召唤。剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61027400,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61027401)
	e2:SetTarget(c61027400.target)
	e2:SetOperation(c61027400.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片是否为表侧表示的「舍利军贯」。
function c61027400.sprfilter(c)
	return c:IsFaceup() and c:IsCode(24639891)
end
-- ①效果的特殊召唤条件函数：检查自己怪兽区有空位且场上存在表侧表示的「舍利军贯」。
function c61027400.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在可用于特殊召唤的空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示的「舍利军贯」。
		and Duel.IsExistingMatchingCard(c61027400.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的目标处理函数：检查卡组至少有3张卡且卡组顶3张卡中存在可加入手卡的卡，或在有空位且无特招封锁时能进行特殊召唤。
function c61027400.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方3张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,3)
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动条件检查：确认自己卡组至少剩余3张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and (g:IsExists(Card.IsAbleToHand,1,nil) or ft>0
		-- 检查在怪兽区有空位时玩家是否可以进行特殊召唤，且未受烈焰侠或右枢α等特殊召唤限制影响。
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)) end
end
-- 过滤条件：检查卡片是否为「舍利军贯」且可加入手卡或在有空位时可特殊召唤。
function c61027400.filter(c,e,tp,ft)
	return c:IsCode(24639891) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的处理函数：翻开卡组最上方3张卡，若有「舍利军贯」则询问玩家选择1只加入手卡或特殊召唤，最后洗切卡组。
function c61027400.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方3张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,3)
	if #g==3 then
		-- 向双方翻开确认自己卡组最上方3张卡。
		Duel.ConfirmDecktop(tp,3)
		-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local tg=g:Filter(c61027400.filter,nil,e,tp,ft)
		-- 若翻开的卡中存在可操作的「舍利军贯」，询问玩家是否选1只加入手卡或特殊召唤。
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(61027400,1)) then  --"是否选卡加入手卡或特殊召唤？"
			-- 发送提示信息，引导玩家选择要操作的「舍利军贯」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local sg=tg:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			-- 若所选「舍利军贯」可加入手卡，且没有空位、不能特招或玩家选择加入手卡时进入加入手卡分支。
			if tc:IsAbleToHand() and (ft<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将所选「舍利军贯」以效果加入自己手卡。
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 将加入手卡的「舍利军贯」展示给对方确认。
				Duel.ConfirmCards(1-tp,tc)
			else
				-- 将所选「舍利军贯」以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		-- 将剩下的卡放回并洗切自己的卡组。
		Duel.ShuffleDeck(tp)
	end
end

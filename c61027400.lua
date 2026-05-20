--いくらの軍貫
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「舍利军贯」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1只「舍利军贯」加入手卡或特殊召唤。剩下的卡回到卡组。
function c61027400.initial_effect(c)
	-- ①：自己场上有「舍利军贯」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61027400+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c61027400.sprcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1只「舍利军贯」加入手卡或特殊召唤。剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61027400,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61027401)
	e2:SetTarget(c61027400.target)
	e2:SetOperation(c61027400.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的「舍利军贯」
function c61027400.sprfilter(c)
	return c:IsFaceup() and c:IsCode(24639891)
end
-- 特殊召唤规则的条件：自己场上有「舍利军贯」存在且有可用怪兽区域
function c61027400.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「舍利军贯」
		and Duel.IsExistingMatchingCard(c61027400.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动准备与可行性检测
function c61027400.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查自己卡组的卡片数量是否在3张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and (g:IsExists(Card.IsAbleToHand,1,nil) or ft>0
		-- 检查玩家是否可以进行特殊召唤，且未受到无法特殊召唤的限制效果影响
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)) end
end
-- 过滤条件：卡名为「舍利军贯」，且可以加入手卡或可以特殊召唤
function c61027400.filter(c,e,tp,ft)
	return c:IsCode(24639891) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的实际处理：翻开卡组上方3张卡，选择1张「舍利军贯」加入手卡或特殊召唤，其余卡回到卡组
function c61027400.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if #g==3 then
		-- 确认（翻开）自己卡组最上方的3张卡
		Duel.ConfirmDecktop(tp,3)
		-- 获取自己场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local tg=g:Filter(c61027400.filter,nil,e,tp,ft)
		-- 如果翻开的卡中有符合条件的「舍利军贯」，询问玩家是否将其加入手卡或特殊召唤
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(61027400,1)) then  --"是否选卡加入手卡或特殊召唤？"
			-- 提示玩家选择要操作的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local sg=tg:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			-- 判断是否只能加入手卡，或者在满足特殊召唤条件时由玩家选择加入手卡
			if tc:IsAbleToHand() and (ft<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将选中的卡加入手卡
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,tc)
			else
				-- 将选中的卡在自己场上表侧表示特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		-- 将剩下的卡回到卡组并洗牌
		Duel.ShuffleDeck(tp)
	end
end

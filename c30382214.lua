--花札衛－桜－
-- 效果：
-- ①：自己场上有2星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ②：1回合1次，把自己场上1只「花札卫」怪兽解放才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以从卡组把「花札卫-樱-」以外的1只「花札卫」怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
function c30382214.initial_effect(c)
	-- 效果原文内容：①：自己场上有2星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c30382214.spcon)
	e1:SetTarget(c30382214.sptg)
	e1:SetOperation(c30382214.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，把自己场上1只「花札卫」怪兽解放才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以从卡组把「花札卫-樱-」以外的1只「花札卫」怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30382214.drawcost)
	e2:SetTarget(c30382214.drawtg)
	e2:SetOperation(c30382214.drawop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在2星以下的「花札卫」怪兽
function c30382214.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(2)
end
-- 效果发动条件判断，检查自己场上是否存在2星以下的「花札卫」怪兽
function c30382214.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在2星以下的「花札卫」怪兽
	return Duel.IsExistingMatchingCard(c30382214.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的处理条件，检查是否有足够的召唤位置和自身是否可以特殊召唤
function c30382214.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置特殊召唤的效果信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将自身特殊召唤到场上，并设置不能召唤/特殊召唤「花札卫」怪兽的效果
function c30382214.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册不能特殊召唤「花札卫」怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c30382214.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将不能召唤的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能召唤/特殊召唤的怪兽类型
function c30382214.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 效果处理函数，检查并选择解放1只「花札卫」怪兽作为cost
function c30382214.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只「花札卫」怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xe6) end
	-- 选择1只「花札卫」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xe6)
	-- 将选择的怪兽进行解放
	Duel.Release(g,REASON_COST)
end
-- 设置抽卡效果的处理条件
function c30382214.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标数量
	Duel.SetTargetParam(1)
	-- 设置抽卡的效果信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤函数，检查卡组中是否存在可加入手牌或特殊召唤的「花札卫」怪兽
function c30382214.sfilter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and not c:IsCode(30382214)
		-- 检查该怪兽是否可以加入手牌或特殊召唤
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果处理函数，执行抽卡并处理抽到的卡
function c30382214.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取抽卡操作实际操作的卡片
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 给对方确认抽到的卡
		Duel.ConfirmCards(1-p,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			local sel=1
			-- 提示玩家选择是否将卡加入手牌或特殊召唤
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30382214,0))  --"是否把「花札卫」怪兽加入手卡或特殊召唤？"
			-- 检查卡组中是否存在满足条件的「花札卫」怪兽
			if Duel.IsExistingMatchingCard(c30382214.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
				-- 选择将卡加入手牌或特殊召唤
				sel=Duel.SelectOption(tp,1213,1214)
			else
				-- 选择将卡特殊召唤
				sel=Duel.SelectOption(tp,1214)+1
			end
			if sel==0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 提示玩家选择要操作的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
				-- 选择卡组中满足条件的「花札卫」怪兽
				local sc=Duel.SelectMatchingCard(tp,c30382214.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
				-- 检查是否有足够的召唤位置
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
					-- 判断是否选择特殊召唤
					and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
					-- 将选择的怪兽特殊召唤到场上
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				else
					-- 将选择的怪兽加入手牌
					Duel.SendtoHand(sc,nil,REASON_EFFECT)
					-- 给对方确认加入手牌的卡
					Duel.ConfirmCards(1-tp,sc)
				end
			end
		else
			-- 将抽到的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	end
end

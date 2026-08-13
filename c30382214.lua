--花札衛－桜－
-- 效果：
-- ①：自己场上有2星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ②：1回合1次，把自己场上1只「花札卫」怪兽解放才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以从卡组把「花札卫-樱-」以外的1只「花札卫」怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
function c30382214.initial_effect(c)
	-- ①：自己场上有2星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c30382214.spcon)
	e1:SetTarget(c30382214.sptg)
	e1:SetOperation(c30382214.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上1只「花札卫」怪兽解放才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以从卡组把「花札卫-樱-」以外的1只「花札卫」怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
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
-- 过滤条件：怪兽需表侧表示、属于「花札卫」字段且等级在2星以下，用于检查①的发动条件。
function c30382214.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(2)
end
-- 效果①的发动条件：检查自己场上是否存在至少1只表侧表示的2星以下「花札卫」怪兽。
function c30382214.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只以上满足cfilter条件的「花札卫」怪兽。
	return Duel.IsExistingMatchingCard(c30382214.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动合法性检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c30382214.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 登记效果处理时会将这张卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：若这张卡仍与效果关联则将其特殊召唤；随后给自己施加直到回合结束时不能召唤·特殊召唤非「花札卫」怪兽的限制。
function c30382214.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。②：1回合1次，把自己场上1只「花札卫」怪兽解放才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以从卡组把「花札卫-樱-」以外的1只「花札卫」怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c30382214.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤非花札卫怪兽”的永续限制效果注册给当前玩家。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将“不能召唤非花札卫怪兽”的永续限制效果注册给当前玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 限制效果判定：被检查的怪兽不是「花札卫」字段时，不能进行召唤或特殊召唤。
function c30382214.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 效果②的发动代价：解放自己场上1只「花札卫」怪兽作为cost。
function c30382214.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的「花札卫」怪兽作为发动代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xe6) end
	-- 选择自己场上1只「花札卫」怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xe6)
	-- 将选择的「花札卫」怪兽解放，作为效果发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果②的目标设定：抽1张卡，并设置对应的对象玩家、数量和操作信息。
function c30382214.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够通过效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，表示抽卡玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记效果处理时抽1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 检索/特殊召唤的候选卡过滤：必须是「花札卫」怪兽、不是「花札卫-樱-」本身，且能够加入手卡或能够特殊召唤。
function c30382214.sfilter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and not c:IsCode(30382214)
		-- 候选卡额外要求：可以加入手卡，或自己场上有空位且该卡能够被特殊召唤。
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果②处理：抽1张并展示，若抽到「花札卫」怪兽则可由玩家选择是否从卡组将另一只「花札卫」怪兽加入手卡或特殊召唤，否则将抽到的卡送去墓地；最后洗切手牌。
function c30382214.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若实际抽卡成功则继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 取得刚才抽到的那张卡。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-p,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			local sel=1
			-- 弹出选择提示，询问是否将「花札卫」怪兽加入手卡或特殊召唤。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30382214,0))  --"是否把「花札卫」怪兽加入手卡或特殊召唤？"
			-- 检查卡组中是否存在满足条件的「花札卫」怪兽可供检索或特殊召唤。
			if Duel.IsExistingMatchingCard(c30382214.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
				-- 让玩家选择是否处理从卡组把「花札卫」怪兽加入手卡或特殊召唤的效果（是/否）。
				sel=Duel.SelectOption(tp,1213,1214)
			else
				-- 卡组无候选时强制选择不处理，使sel为1。
				sel=Duel.SelectOption(tp,1214)+1
			end
			if sel==0 then
				-- 中断当前效果处理，使后续操作视为另一次效果处理，避免错时点。
				Duel.BreakEffect()
				-- 提示玩家选择要操作的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
				-- 从卡组选择1张满足条件的「花札卫」怪兽。
				local sc=Duel.SelectMatchingCard(tp,c30382214.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
				-- 检查自己场上有空位且该卡可以被特殊召唤。
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
					-- 进一步判断：若该卡不能加入手卡则必须特殊召唤；若能加入手卡，则让玩家选择加入手卡或特殊召唤，选1表示特殊召唤。
					and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
					-- 将选择的「花札卫」怪兽特殊召唤到自己场上。
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				else
					-- 将选择的「花札卫」怪兽加入持有者手卡。
					Duel.SendtoHand(sc,nil,REASON_EFFECT)
					-- 将加入手卡的这张卡展示给对方确认。
					Duel.ConfirmCards(1-tp,sc)
				end
			end
		else
			-- 抽到的卡不是「花札卫」怪兽时，将其送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切自己的手牌，整理手牌顺序。
		Duel.ShuffleHand(tp)
	end
end

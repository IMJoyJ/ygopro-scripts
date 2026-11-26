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
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30382214.drawcost)
	e2:SetTarget(c30382214.drawtg)
	e2:SetOperation(c30382214.drawop)
	c:RegisterEffect(e2)
end
-- 过滤己方场上表侧表示、2星以下的「花札卫」怪兽
function c30382214.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(2)
end
-- 检查①效果发动条件：己方怪兽区存在2星以下的「花札卫」怪兽
function c30382214.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方怪兽区是否存在至少1只满足cfilter条件的2星以下「花札卫」怪兽
	return Duel.IsExistingMatchingCard(c30382214.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动前确认己方怪兽区有空位且手卡的此卡可以特殊召唤
function c30382214.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区是否至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将手卡的此卡表侧表示特殊召唤到己方场上，并施加直到回合结束时不能召唤·特殊召唤「花札卫」以外怪兽的自肃限制
function c30382214.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到己方场上
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
	-- 为己方玩家注册持续至回合结束的特殊召唤自肃效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 为己方玩家注册持续至回合结束的通常召唤自肃效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件函数：阻止召唤或特殊召唤「花札卫」以外的怪兽
function c30382214.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 支付②效果的发动代价：选择并解放己方场上1只「花札卫」怪兽
function c30382214.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认己方场上是否存在至少1只可解放的「花札卫」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xe6) end
	-- 让己方从己方场上选择1只可解放的「花札卫」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xe6)
	-- 将选中的「花札卫」怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 发动前确认己方可以抽1张卡，并设置目标玩家、抽卡数量与抽卡操作信息
function c30382214.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方玩家是否可以进行1张卡的效果抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为己方
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的抽卡数量参数为1
	Duel.SetTargetParam(1)
	-- 登记己方从卡组抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤卡组中除「花札卫-樱-」外、可加入手卡或在怪兽区有空位时可特殊召唤的「花札卫」怪兽
function c30382214.sfilter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and not c:IsCode(30382214)
		-- 判断该卡能否加入手卡，或在己方怪兽区有空位时能否被特殊召唤
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ②效果处理：抽1张卡并给双方确认，若为「花札卫」怪兽则可选择从卡组将另1只「花札卫」怪兽加入手卡或特召，否则将抽到的卡送去墓地，最后洗切手卡
function c30382214.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁设定的目标玩家p和抽卡数量d
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡并判断是否成功抽到卡片
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚才通过抽卡操作抽到的卡片
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 向对方玩家展示抽到的卡片进行确认
		Duel.ConfirmCards(1-p,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			local sel=1
			-- 向己方发送是否从卡组检索或特殊召唤「花札卫」怪兽的提示
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30382214,0))  --"是否把「花札卫」怪兽加入手卡或特殊召唤？"
			-- 检查己方卡组中是否存在符合sfilter条件的其他「花札卫」怪兽
			if Duel.IsExistingMatchingCard(c30382214.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
				-- 卡组有目标时，让玩家选择「是」或「否」以决定是否执行检索/特召
				sel=Duel.SelectOption(tp,1213,1214)
			else
				-- 卡组无可用目标时，仅提供「否」选项供玩家确认
				sel=Duel.SelectOption(tp,1214)+1
			end
			if sel==0 then
				-- 插入效果处理间断，使抽卡确认与后续卡组检索/特召视为不同时处理
				Duel.BreakEffect()
				-- 向己方发送从卡组选择要操作的「花札卫」怪兽的提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
				-- 让己方从卡组选择1只符合条件的「花札卫」怪兽
				local sc=Duel.SelectMatchingCard(tp,c30382214.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
				-- 检查己方怪兽区是否有空位且选中的怪兽可以被特殊召唤
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
					-- 若无法加入手卡或玩家在选项中选择特殊召唤，则进入特殊召唤分支
					and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
					-- 将选中的「花札卫」怪兽以表侧表示特殊召唤到己方场上
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				else
					-- 将选中的「花札卫」怪兽以效果加入持有者手卡
					Duel.SendtoHand(sc,nil,REASON_EFFECT)
					-- 向对方玩家展示加入手卡的「花札卫」怪兽进行确认
					Duel.ConfirmCards(1-tp,sc)
				end
			end
		else
			-- 抽到的不是「花札卫」怪兽时，将其以效果送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切己方手卡以重置手卡公开状态检测
		Duel.ShuffleHand(tp)
	end
end

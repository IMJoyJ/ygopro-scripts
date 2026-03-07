--烙印の気炎
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡1只怪兽给对方观看，和那只怪兽相同种族而攻击力或守备力是2500的1只8星融合怪兽从额外卡组送去墓地。那之后，以下效果可以适用。
-- ●给人观看的怪兽丢弃，把1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
-- ②：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
function c29948294.initial_effect(c)
	-- 记录该卡牌效果文本上记载着「阿不思的落胤」这张卡
	aux.AddCodeList(c,68468459)
	-- ①：把手卡1只怪兽给对方观看，和那只怪兽相同种族而攻击力或守备力是2500的1只8星融合怪兽从额外卡组送去墓地。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29948294,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29948294)
	e1:SetTarget(c29948294.target)
	e1:SetOperation(c29948294.activate)
	c:RegisterEffect(e1)
	-- ②：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29948294,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,29948294)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c29948294.thcon)
	e2:SetTarget(c29948294.thtg)
	e2:SetOperation(c29948294.thop)
	c:RegisterEffect(e2)
	if not c29948294.global_check then
		c29948294.global_check=true
		-- 注册一个全局时点效果，用于检测是否有融合怪兽被送去墓地
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c29948294.checkop)
		-- 将全局时点效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义一个过滤函数，用于判断卡是否为融合怪兽且为指定玩家控制
function c29948294.checkfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 定义一个处理函数，当有融合怪兽被送去墓地时，为对应玩家注册标识效果
function c29948294.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果满足条件，则为玩家0注册一个标识效果
	if eg:IsExists(c29948294.checkfilter,1,nil,0) then Duel.RegisterFlagEffect(0,29948294,RESET_PHASE+PHASE_END,0,1) end
	-- 如果满足条件，则为玩家1注册一个标识效果
	if eg:IsExists(c29948294.checkfilter,1,nil,1) then Duel.RegisterFlagEffect(1,29948294,RESET_PHASE+PHASE_END,0,1) end
end
-- 定义一个过滤函数，用于判断手牌中是否存在未公开的怪兽且该怪兽对应种族存在满足条件的融合怪兽
function c29948294.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
		-- 检查是否存在满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c29948294.tgfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetRace())
end
-- 定义一个过滤函数，用于判断额外卡组中是否存在满足条件的8星融合怪兽
function c29948294.tgfilter(c,race)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsRace(race)
		and c:IsLevel(8) and c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end
-- 定义效果的目标函数，检查是否存在满足条件的手牌怪兽
function c29948294.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的手牌怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29948294.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置连锁操作信息，表示将要从额外卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 定义一个过滤函数，用于判断卡组中是否存在「阿不思的落胤」或其衍生物
function c29948294.thfilter(c)
	-- 判断卡是否为「阿不思的落胤」或其衍生物且能加入手牌
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 定义效果的发动函数，执行效果的主要逻辑
function c29948294.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的手牌怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的手牌怪兽
	local g=Duel.SelectMatchingCard(tp,c29948294.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local cc=g:GetFirst()
	if cc then
		-- 向对方确认所选怪兽
		Duel.ConfirmCards(1-tp,cc)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		local race=cc:GetRace()
		-- 提示玩家选择要送去墓地的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的融合怪兽
		local tg=Duel.SelectMatchingCard(tp,c29948294.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,race)
		local tc=tg:GetFirst()
		-- 将融合怪兽送去墓地并检查是否成功
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
			-- 获取卡组中满足条件的卡
			local g=Duel.GetMatchingGroup(c29948294.thfilter,tp,LOCATION_DECK,0,nil)
			-- 判断是否满足丢弃怪兽并加入手牌的条件
			if #g>0 and cc:IsDiscardable() and Duel.SelectYesNo(tp,aux.Stringid(29948294,2)) then  --"是否丢弃观看的怪兽，并把卡加入手卡？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将所选怪兽丢弃
				Duel.SendtoGrave(cc,REASON_EFFECT+REASON_DISCARD)
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 将卡加入手牌
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 向对方确认所选卡
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end
-- 定义效果的发动条件函数，检查是否在本回合有融合怪兽被送去墓地
function c29948294.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否拥有标识效果
	return Duel.GetFlagEffect(tp,29948294)~=0
end
-- 定义效果的发动目标函数，设置将墓地的卡加入手牌
function c29948294.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义效果的发动处理函数，执行将卡加入手牌的操作
function c29948294.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

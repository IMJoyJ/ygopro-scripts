--キラーチューン・ロタリー
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只调整给对方观看才能发动。进行1只调整的召唤。
-- ②：这张卡作为同调素材送去墓地的场合，可以从以下效果选择1个发动。
-- ●从对方墓地让1张卡回到卡组最下面。
-- ●对方手卡全部确认。那之后，可以从卡组把1张「杀手级调整曲」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：手牌同步、召唤效果、作为同步素材时的效果
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- 把手卡的这张卡和手卡1只调整给对方观看才能发动。进行1只调整的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.sumcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- 这张卡作为同调素材送去墓地的场合，可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"作为同调素材送去墓地"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
	s.killer_tune_be_material_effect=e3
end
-- 过滤函数，用于判断是否为同步素材的调整怪兽
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 条件函数，判断此卡是否在场上
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 过滤函数，用于判断手牌中是否有未公开的调整怪兽
function s.cfilter(c)
	return c:IsType(TYPE_TUNER) and not c:IsPublic()
end
-- 召唤效果的费用支付函数，确认手牌中的调整怪兽并展示给对方
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足召唤效果的费用条件
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要展示给对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手牌中满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 过滤函数，用于判断是否为可通常召唤的调整怪兽
function s.sumfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSummonable(true,nil)
end
-- 召唤效果的目标设定函数，检查是否有可召唤的调整怪兽
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足召唤效果的目标条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤效果的处理函数，选择并进行调整怪兽的通常召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行调整怪兽的通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果发动条件函数，判断此卡是否因同步召唤而进入墓地
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于判断卡组中是否有杀手级调整曲魔法或陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1d5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果的目标设定函数，选择发动效果的选项
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否有可送回卡组的卡
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
	-- 检查对方手牌是否为空
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return b1 or b2 end
	-- 选择发动效果的选项
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"对方墓地让1张卡回到卡组最下面"
		{b2,aux.Stringid(id,3),2})  --"确认对方手卡"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
		end
		-- 设置效果处理信息，将对方墓地的卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		end
	end
end
-- 效果的处理函数，根据选择的选项执行相应效果
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择对方墓地中满足条件的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将卡送回对方卡组最底端
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	elseif op==2 then
		-- 获取对方手牌
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g>0 then
			-- 确认对方手牌
			Duel.ConfirmCards(tp,g)
			-- 获取卡组中满足条件的魔法或陷阱卡
			local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			-- 询问是否将魔法或陷阱卡加入手牌
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把魔法·陷阱卡加入手卡？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将卡加入手牌
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 向对方确认所选卡
				Duel.ConfirmCards(1-tp,tg)
			end
			-- 洗切对方手牌
			Duel.ShuffleHand(1-tp)
		end
	end
end

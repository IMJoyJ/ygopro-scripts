--メルフィーがころんだ
-- 效果：
-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
local s,id,o=GetID()
-- 注册检索并强制结束回合效果、墓地除外回收「童话动物」卡片的效果、以及限制非「童话动物」怪兽特召的全局计数器
function s.initial_effect(c)
	-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将墓地的此卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 注册全局自定义特殊召唤监视计数器以支持特召誓约限制
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 誓约所限定只允许特殊召唤的「童话动物」怪兽的过滤条件
function s.counterfilter(c)
	return c:IsSetCard(0x146) and c:IsFaceup()
end
-- 特殊召唤誓约限制检查与单回合持续限制效果注册
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己本回合在发动此卡前是否进行过非「童话动物」怪兽的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 在自己玩家身上注册本回合只能特殊召唤「童话动物」怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 禁止特殊召唤非「童话动物」怪兽的限制条件
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x146)
end
-- 可检索并加入手卡的「童话动物」怪兽的过滤条件
function s.thfilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 卡组检索效果的发动准备
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可检索的「童话动物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 卡组检索并强行结束回合效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「童话动物」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择最多4只且同名卡最多1张的「童话动物」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,4)
	-- 将选中的怪兽从卡组加入手卡
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 若有怪兽成功加入手卡，则跳过自己当前的主要阶段1
			Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
			-- 若有怪兽成功加入手卡，则跳过自己当前的战斗阶段
			Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
			-- 若有怪兽成功加入手卡，则直接将当前回合推进至结束阶段
			Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
			-- 并在本回合内，注册自己无法进入战斗阶段的额外限制效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将禁止进入战斗阶段的玩家持续效果注册给系统
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 可作为回收对象的墓地「童话动物」卡片的过滤条件（需排除同名卡及特殊卡）
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsSetCard(0x146) and c:IsAbleToHand() and c:IsAbleToDeck()
end
-- 墓地卡片回收效果的发动准备与对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	-- 检查墓地是否存在至少2张符合过滤条件的「童话动物」卡片
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,2,c) end
	-- 向玩家发送提示，请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地中2张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,2,2,c)
	-- 设置操作信息为将其中1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息为将其中1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 墓地卡片回收效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前效果关联且未受墓地无效影响的2张墓地卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()>0 then
		if tg:GetCount()==1 then
			if tg:IsExists(Card.IsAbleToHand,1,nil) then
				-- 若由于连锁破坏只剩1个目标，且该卡可以加入手卡，则将其加入手卡
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 向对方玩家展示成功加入手卡的卡片
				Duel.ConfirmCards(1-tp,tg)
			end
		else
			-- 向玩家发送提示，请选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			if sg:IsExists(Card.IsAbleToHand,1,nil) then
				tg:Sub(sg)
				-- 从2张目标卡片中选择1张加入手卡，并将其从目标卡片组中移除
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 向对方玩家展示成功加入手卡的那张卡片
				Duel.ConfirmCards(1-tp,sg)
				if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
					-- 若加入手卡处理成功，则将终点处的另1张目标卡片送回卡组最下方
					Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end

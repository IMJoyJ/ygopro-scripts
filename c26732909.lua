--魔導教士 システィ
-- 效果：
-- 自己把名字带有「魔导书」的魔法卡发动的自己回合的结束阶段时，把场上的这张卡从游戏中除外才能发动。从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽和1张名字带有「魔导书」的魔法卡加入手卡。「魔导教士 朱丝蒂」的效果1回合只能使用1次。
function c26732909.initial_effect(c)
	-- 自己把名字带有「魔导书」的魔法卡发动的自己回合的结束阶段时，把场上的这张卡从游戏中除外才能发动。从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽和1张名字带有「魔导书」的魔法卡加入手卡。「魔导教士 朱丝蒂」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26732909,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26732909)
	e1:SetCondition(c26732909.thcon)
	e1:SetCost(c26732909.thcost)
	e1:SetTarget(c26732909.thtg)
	e1:SetOperation(c26732909.thop)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，用于记录本回合是否发动过名字带有「魔导书」的魔法卡（通过ACTIVITY_CHAIN类型计数）。
	Duel.AddCustomActivityCounter(26732909,ACTIVITY_CHAIN,c26732909.chainfilter)
end
-- 定义计数器过滤函数：如果连锁发动的效果是「魔导书」魔法卡的发动则返回false使计数器增加，其他发动返回true不计数。
function c26732909.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x106e))
end
-- 效果发动条件函数：必须是自己回合的结束阶段（当前回合玩家是这张卡的控制者）才能发动。
function c26732909.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者tp，是则条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 代价函数：确认本回合发动过「魔导书」魔法卡且这张卡能作为代价除外，然后将场上的这张卡表侧表示除外。
function c26732909.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查本回合是否发动过「魔导书」魔法卡（计数>0）以及此卡能否作为代价除外。
	if chk==0 then return Duel.GetCustomActivityCount(26732909,tp,ACTIVITY_CHAIN)>0 and e:GetHandler():IsAbleToRemoveAsCost() end
	-- 执行代价：将这张卡从游戏中表侧表示除外作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 检索怪兽的筛选函数：选择1只等级5以上、光属性或暗属性、魔法师族且能加入手卡的怪兽。
function c26732909.filter1(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 检索魔法卡的筛选函数：选择1张名字带有「魔导书」的魔法卡且能加入手卡。
function c26732909.filter2(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x106e) and c:IsAbleToHand()
end
-- 效果发动目标条件：确认卡组中同时存在符合条件的怪兽和「魔导书」魔法卡各至少1张。
function c26732909.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1只以上满足filter1条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c26732909.filter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组中是否存在1张以上满足filter2条件的「魔导书」魔法卡。
		and Duel.IsExistingMatchingCard(c26732909.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：本次效果将把卡组中的2张卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组分别选出符合条件的1只怪兽和1张「魔导书」魔法卡，加入手牌并让对方确认。
function c26732909.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有满足filter1条件的怪兽卡组。
	local g1=Duel.GetMatchingGroup(c26732909.filter1,tp,LOCATION_DECK,0,nil)
	-- 取得卡组中所有满足filter2条件的「魔导书」魔法卡组。
	local g2=Duel.GetMatchingGroup(c26732909.filter2,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择要加入手牌的怪兽卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要加入手牌的魔法卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选择的两张卡加入持有者的手卡（效果处理）。
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg1)
	end
end

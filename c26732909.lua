--魔導教士 システィ
-- 效果：
-- 自己把名字带有「魔导书」的魔法卡发动的自己回合的结束阶段时，把场上的这张卡从游戏中除外才能发动。从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽和1张名字带有「魔导书」的魔法卡加入手卡。「魔导教士 朱丝蒂」的效果1回合只能使用1次。
function c26732909.initial_effect(c)
	-- 效果原文内容：自己把名字带有「魔导书」的魔法卡发动的自己回合的结束阶段时，把场上的这张卡从游戏中除外才能发动。
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
	-- 设置操作类型为发动效果、代号为26732909的计数器，用于限制「魔导教士 朱丝蒂」的效果1回合只能使用1次。
	Duel.AddCustomActivityCounter(26732909,ACTIVITY_CHAIN,c26732909.chainfilter)
end
-- 过滤函数，用于判断是否为发动了名字带有「魔导书」的魔法卡的连锁，若是则该连锁不计入计数器。
function c26732909.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x106e))
end
-- 效果原文内容：自己把名字带有「魔导书」的魔法卡发动的自己回合的结束阶段时，把场上的这张卡从游戏中除外才能发动。
function c26732909.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者，确保效果只在自己回合发动。
	return Duel.GetTurnPlayer()==tp
end
-- 效果原文内容：自己把名字带有「魔导书」的魔法卡发动的自己回合的结束阶段时，把场上的这张卡从游戏中除外才能发动。
function c26732909.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：当前回合玩家已发动过非「魔导书」魔法卡的连锁，且本卡可作为代价除外。
	if chk==0 then return Duel.GetCustomActivityCount(26732909,tp,ACTIVITY_CHAIN)>0 and e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将本卡从场上除外作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检索卡组中满足条件的光属性或暗属性魔法师族5星以上的怪兽。
function c26732909.filter1(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 过滤函数，用于检索卡组中名字带有「魔导书」的魔法卡。
function c26732909.filter2(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x106e) and c:IsAbleToHand()
end
-- 效果原文内容：从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽和1张名字带有「魔导书」的魔法卡加入手卡。
function c26732909.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的光属性或暗属性魔法师族5星以上的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c26732909.filter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组中是否存在满足条件的名字带有「魔导书」的魔法卡。
		and Duel.IsExistingMatchingCard(c26732909.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将从卡组检索2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果原文内容：从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽和1张名字带有「魔导书」的魔法卡加入手卡。
function c26732909.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的光属性或暗属性魔法师族5星以上的怪兽组。
	local g1=Duel.GetMatchingGroup(c26732909.filter1,tp,LOCATION_DECK,0,nil)
	-- 检索满足条件的名字带有「魔导书」的魔法卡组。
	local g2=Duel.GetMatchingGroup(c26732909.filter2,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择要加入手牌的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要加入手牌的魔法卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选择的卡组送入手牌。
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡。
		Duel.ConfirmCards(1-tp,sg1)
	end
end

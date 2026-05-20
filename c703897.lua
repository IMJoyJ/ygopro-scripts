--オルフェゴール・クリマクス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「自奏圣乐」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。
-- ②：把墓地的这张卡除外才能发动（这个效果发动的回合，自己不是机械族·暗属性怪兽不能特殊召唤）。自己的卡组·除外状态的1只机械族·暗属性怪兽加入手卡。
function c703897.initial_effect(c)
	-- ①：自己场上有「自奏圣乐」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,703897)
	e1:SetCondition(c703897.condition)
	-- 设置效果1的操作分类为无效和除外
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c703897.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动（这个效果发动的回合，自己不是机械族·暗属性怪兽不能特殊召唤）。自己的卡组·除外状态的1只机械族·暗属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,703897)
	e2:SetCost(c703897.thcost)
	e2:SetTarget(c703897.thtg)
	e2:SetOperation(c703897.thop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于记录本回合特殊召唤过非机械族·暗属性怪兽的次数
	Duel.AddCustomActivityCounter(703897,ACTIVITY_SPSUMMON,c703897.counterfilter)
end
-- 计数器过滤函数：检查特殊召唤的怪兽是否为机械族·暗属性
function c703897.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤条件：自己场上表侧表示的「自奏圣乐」连接怪兽
function c703897.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11b) and c:IsType(TYPE_LINK)
end
-- 效果1的发动条件：自己场上有「自奏圣乐」连接怪兽存在，且有可以被无效的怪兽效果、魔法、陷阱卡发动
function c703897.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「自奏圣乐」连接怪兽
	return Duel.IsExistingMatchingCard(c703897.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查被连锁的效果是否可以被无效，且该效果是怪兽效果、魔法或陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果1的效果处理：使发动的效果无效并除外
function c703897.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在原本的连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果2的Cost处理：检查本回合是否只特殊召唤过机械族·暗属性怪兽，并将墓地的这张卡除外，同时适用特殊召唤限制
function c703897.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合在发动此效果前，是否没有特殊召唤过非机械族·暗属性的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(703897,tp,ACTIVITY_SPSUMMON)==0
		-- 检查是否可以将墓地的这张卡除外作为Cost
		and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- （这个效果发动的回合，自己不是机械族·暗属性怪兽不能特殊召唤）。自己的卡组·除外状态的1只机械族·暗属性怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c703897.splimit)
	-- 给玩家注册不能特殊召唤非机械族·暗属性怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 执行Cost：将墓地的这张卡除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 特殊召唤限制：不能特殊召唤非机械族·暗属性的怪兽
function c703897.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK))
end
-- 过滤条件：卡组或除外状态的机械族·暗属性怪兽
function c703897.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- 效果2的Target处理：检查是否存在可检索的怪兽，并设置操作信息
function c703897.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或除外状态是否存在至少1只满足条件的机械族·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c703897.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：从卡组或除外状态将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 效果2的效果处理：从卡组或除外状态选择1只机械族·暗属性怪兽加入手牌
function c703897.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或除外状态选择1只满足条件的机械族·暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c703897.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

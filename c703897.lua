--オルフェゴール・クリマクス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「自奏圣乐」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。
-- ②：把墓地的这张卡除外才能发动（这个效果发动的回合，自己不是机械族·暗属性怪兽不能特殊召唤）。自己的卡组·除外状态的1只机械族·暗属性怪兽加入手卡。
function c703897.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「自奏圣乐」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,703897)
	e1:SetCondition(c703897.condition)
	-- 设置无效并除外效果的Target函数，用于检验和声明无效并除外的目标信息
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c703897.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外才能发动（这个效果发动的回合，自己不是机械族·暗属性怪兽不能特殊召唤）。自己的卡组·除外状态的1只机械族·暗属性怪兽加入手卡。
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
	-- 注册一个特殊的特殊召唤活动计数器，用于记录玩家特殊召唤非机械族·暗属性怪兽的次数
	Duel.AddCustomActivityCounter(703897,ACTIVITY_SPSUMMON,c703897.counterfilter)
end
-- 特殊召唤计数器的过滤函数，检测怪兽是否为表侧表示的机械族·暗属性怪兽
function c703897.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
-- 过滤自己场上的表侧表示「自奏圣乐」连接怪兽
function c703897.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11b) and c:IsType(TYPE_LINK)
end
-- 效果①的发动条件：自己场上有「自奏圣乐」连接怪兽存在，且可以无效该连锁的发动，且发动的卡是怪兽效果或魔法·陷阱卡
function c703897.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「自奏圣乐」连接怪兽
	return Duel.IsExistingMatchingCard(c703897.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查该连锁的发动是否可以被无效，且该发动是怪兽的效果、魔法或陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果①的运作函数：尝试无效发动，并在成功且卡片与效果关联时将其表侧表示除外
function c703897.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效发动的效果，且发动的卡与该连锁的效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将发动的卡表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的Cost函数，在chk==0时检测玩家在本回合是否未进行过机械族·暗属性怪兽以外的特殊召唤，并检测此卡是否能除外
function c703897.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若检测发动条件，则检查本回合玩家是否未特殊召唤过机械族·暗属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(703897,tp,ACTIVITY_SPSUMMON)==0
		-- 且检查墓地中的这张卡是否可以因Cost表侧表示除外
		and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- ②：把墓地的这张卡除外才能发动（这个效果发动的回合，自己不是机械族·暗属性怪兽不能特殊召唤）。自己的卡组·除外状态的1只机械族·暗属性怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c703897.splimit)
	-- 给发动效果的玩家注册不能特殊召唤非机械族·暗属性怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 执行Cost：将墓地的这张卡表侧表示除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 特殊召唤限制过滤函数，非机械族·暗属性怪兽不能特殊召唤
function c703897.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK))
end
-- 过滤卡组或除外状态的机械族·暗属性怪兽（除外状态的怪兽必须是表侧表示）
function c703897.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- 效果②的Target函数，检测并设置将卡组或除外状态的1只机械族·暗属性怪兽加入手牌的操作信息
function c703897.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若检测发动条件，则检查自己卡组或除外状态是否存在至少1只满足条件的机械族·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c703897.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置当前连锁的操作信息：将自己卡组或除外状态的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 效果②的Operation函数，从卡组或除外状态选择1只机械族·暗属性怪兽加入手牌，并向对方确认
function c703897.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或除外状态中选择1只满足条件的机械族·暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c703897.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end

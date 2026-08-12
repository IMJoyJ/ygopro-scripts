--虚光の宣告者
-- 效果：
-- 衍生物以外的相同种族·属性的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法·陷阱卡的效果发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
-- ②：这张卡被对方送去墓地的场合才能发动。从自己墓地的仪式怪兽以及仪式魔法卡之中选合计最多2张加入手卡（同名卡最多1张）。
function c46935289.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用非衍生物且种族与属性相同的2只怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,2,c46935289.lcheck)
	-- ①：魔法·陷阱卡的效果发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46935289,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,46935289)
	e1:SetCondition(c46935289.discon)
	e1:SetCost(c46935289.discost)
	e1:SetTarget(c46935289.distg)
	e1:SetOperation(c46935289.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方送去墓地的场合才能发动。从自己墓地的仪式怪兽以及仪式魔法卡之中选合计最多2张加入手卡（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46935289,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,46935290)
	e2:SetCondition(c46935289.thcon)
	e2:SetTarget(c46935289.thtg)
	e2:SetOperation(c46935289.thop)
	c:RegisterEffect(e2)
end
-- 连接召唤时检查连接素材是否具有相同的属性和种族
function c46935289.lcheck(g,lc)
	-- 检查连接素材是否具有相同的属性和种族
	return aux.SameValueCheck(g,Card.GetLinkAttribute) and aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 效果发动时的条件判断，确保是魔法或陷阱卡的发动且自身未在战斗中被破坏
function c46935289.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为魔法或陷阱卡的发动且自身未在战斗中被破坏，并且连锁可以被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 筛选手卡中可作为cost的天使族怪兽
function c46935289.disfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 支付效果cost，从手卡选择1只天使族怪兽送去墓地
function c46935289.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1只天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46935289.disfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只天使族怪兽作为cost
	local g=Duel.SelectMatchingCard(tp,c46935289.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏目标卡
function c46935289.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使连锁发动无效并破坏目标卡
function c46935289.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标卡仍然有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 触发效果的条件判断，确保是被对方送入墓地
function c46935289.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 筛选墓地中可加入手牌的仪式怪兽或仪式魔法卡
function c46935289.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，包括将卡加入手牌
function c46935289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1张仪式怪兽或仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c46935289.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置将卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 执行效果处理，从墓地选择最多2张仪式怪兽或仪式魔法卡加入手牌
function c46935289.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取满足条件的仪式怪兽或仪式魔法卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c46935289.thfilter),tp,LOCATION_GRAVE,0,nil)
	-- 从符合条件的卡组中选择1到2张不重复卡名的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	if sg and sg:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end

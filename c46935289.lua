--虚光の宣告者
-- 效果：
-- 衍生物以外的相同种族·属性的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法·陷阱卡的效果发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
-- ②：这张卡被对方送去墓地的场合才能发动。从自己墓地的仪式怪兽以及仪式魔法卡之中选合计最多2张加入手卡（同名卡最多1张）。
function c46935289.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「虚光之宣告者」添加连接召唤手续：使用衍生物以外的2只怪兽作为连接素材，且素材需满足lcheck函数（相同属性·相同种族）。
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
-- 定义连接素材的追加检查函数，用于判断所选连接素材是否全部具有相同的连接属性以及相同的连接种族。
function c46935289.lcheck(g,lc)
	-- 检查素材组g中的所有卡片是否拥有共同的连接属性交集，并且拥有共同的连接种族交集，以此满足“相同种族·属性”的素材要求。
	return aux.SameValueCheck(g,Card.GetLinkAttribute) and aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 定义①效果的发动条件：仅在魔法·陷阱卡效果发动时，且自身未被战斗破坏确定、该连锁能够被无效的情况下才能发动。
function c46935289.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动中的效果是否为魔法/陷阱卡效果，自身不处于战斗破坏确定状态，且该连锁可以被无效。
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 定义①效果丢弃手牌天使族怪兽的cost过滤条件：必须为天使族怪兽，并且可以作为cost送去墓地。
function c46935289.disfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- ①效果的cost处理：从手卡选择1只满足条件的天使族怪兽送去墓地，作为发动无效效果所需支付的代价。
function c46935289.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost合法性检查阶段，确认手牌中是否存在至少1只可以送去墓地的天使族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c46935289.disfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向操作玩家显示“选择要送去墓地的卡”的提示消息，用于选择丢弃的天使族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家从手卡中选择1只符合disfilter条件的天使族怪兽，作为发动①效果的cost。
	local g=Duel.SelectMatchingCard(tp,c46935289.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的天使族怪兽从手卡送去墓地，支付①效果的发动cost。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义①效果的发动时目标处理：无条件可发动，设置无效该连锁的操作信息，若被无效的卡可被破坏且仍与效果关联，则再设置破坏该卡的操作信息。
function c46935289.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理包含“使发动无效”，对象为当前正在发动的效果（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的魔法·陷阱卡能够被破坏且仍与效果关联，则追加设置“破坏该卡”的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义①效果的实际处理：尝试无效该魔法·陷阱卡的发动，无效成功且该卡仍与效果关联时，将其破坏。
function c46935289.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁的发动是否被成功无效，且被无效的卡仍与那个效果保持关联（未被离场等原因重置联系）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将因发动无效而关联的魔法·陷阱卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义②效果的发动条件：这张卡被对方送去墓地，且被送去墓地之前由自己控制。
function c46935289.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 定义②效果回收的过滤条件：对象为仪式怪兽或仪式魔法卡（具有仪式类型），并且可以加入手卡。
function c46935289.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 定义②效果发动时的目标检查：确认自己墓地存在至少1张仪式怪兽或仪式魔法卡，并设置从墓地加入手卡的操作信息。
function c46935289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标合法性检查阶段，确认自己墓地中存在至少1张符合条件的仪式怪兽或仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46935289.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：效果处理时将从墓地选择仪式怪兽或仪式魔法卡加入手卡，预计数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 定义②效果的实际处理：从自己墓地的仪式怪兽及仪式魔法卡中，选择最多2张卡名不同的卡加入手卡，并向对方展示。
function c46935289.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取自己墓地中所有满足仪式怪兽/仪式魔法卡条件，且不受“王家长眠之谷”效果影响的卡片。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c46935289.thfilter),tp,LOCATION_GRAVE,0,nil)
	-- 从候选中选择1-2张卡名互不相同的卡片，满足“合计最多2张（同名卡最多1张）”的要求。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	if sg and sg:GetCount()>0 then
		-- 将选中的仪式相关卡加入手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end

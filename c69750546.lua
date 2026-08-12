--ヴォルカニック・バックショット
-- 效果：
-- ①：这张卡被送去墓地的场合发动。给与对方500伤害。
-- ②：这张卡被「烈焰加农炮」卡的效果送去墓地的场合，从手卡·卡组把2只「火山鹿弹」送去墓地才能发动。对方场上的怪兽全部破坏。
function c69750546.initial_effect(c)
	-- ①：这张卡被送去墓地的场合发动。给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69750546,0))  --"给予对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c69750546.target)
	e1:SetOperation(c69750546.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被「烈焰加农炮」卡的效果送去墓地的场合，从手卡·卡组把2只「火山鹿弹」送去墓地才能发动。对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69750546,1))  --"对方场上怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c69750546.descon)
	e2:SetCost(c69750546.descost)
	e2:SetTarget(c69750546.destg)
	e2:SetOperation(c69750546.desop)
	c:RegisterEffect(e2)
end
-- 效果①（伤害效果）的发动准备与目标设置
function c69750546.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了该效果（显示效果描述）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置伤害的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为500
	Duel.SetTargetParam(500)
	-- 设置连锁处理的操作信息为给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果①（伤害效果）的效果处理
function c69750546.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果②的发动条件：检查是否是被「烈焰加农炮」卡片的效果送去墓地
function c69750546.descon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0xb9)
end
-- 过滤手牌或卡组中可以作为代价送去墓地的「火山鹿弹」
function c69750546.costfilter(c)
	return c:IsCode(69750546) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价处理：从手卡·卡组把2只「火山鹿弹」送去墓地
function c69750546.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在至少2张「火山鹿弹」可以作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c69750546.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,2,nil) end
	-- 获取手卡和卡组中所有满足条件的「火山鹿弹」
	local g=Duel.GetMatchingGroup(c69750546.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	if g:GetCount()>2 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		g=g:Select(tp,2,2,nil)
	end
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②（破坏效果）的发动准备与目标设置
function c69750546.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了该效果（显示效果描述）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁处理的操作信息为破坏对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②（破坏效果）的效果处理
function c69750546.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的对方场上的所有怪兽
	Duel.Destroy(g,REASON_EFFECT)
end

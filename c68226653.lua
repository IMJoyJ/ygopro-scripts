--フレムベル・ドラグノフ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，给与对方基本分500分伤害。可以把自己墓地存在的这张卡和自己场上表侧表示存在的1只炎属性怪兽从游戏中除外，从自己卡组把1只「炎狱连射龙」加入手卡。
function c68226653.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68226653,0))  --"给予对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c68226653.damcon)
	e1:SetTarget(c68226653.damtg)
	e1:SetOperation(c68226653.damop)
	c:RegisterEffect(e1)
	-- 可以把自己墓地存在的这张卡和自己场上表侧表示存在的1只炎属性怪兽从游戏中除外，从自己卡组把1只「炎狱连射龙」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68226653,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c68226653.thcost)
	e2:SetTarget(c68226653.thtg)
	e2:SetOperation(c68226653.thop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否被战斗破坏并送去墓地
function c68226653.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置伤害效果的对象与操作信息
function c68226653.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行伤害效果，获取连锁信息并给与对方伤害
function c68226653.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤条件：自己场上表侧表示存在且可以作为Cost除外的炎属性怪兽
function c68226653.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 检索效果的Cost：检查是否能将墓地的此卡和场上1只表侧表示炎属性怪兽除外
function c68226653.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在至少1只满足过滤条件的炎属性怪兽
		and Duel.IsExistingMatchingCard(c68226653.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只满足过滤条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c68226653.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽作为Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中名为「炎狱连射龙」且能加入手卡的怪兽
function c68226653.filter(c)
	return c:IsCode(68226653) and c:IsAbleToHand()
end
-- 检索效果的Target：检查卡组中是否存在「炎狱连射龙」并设置操作信息
function c68226653.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「炎狱连射龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c68226653.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation：从卡组将1只「炎狱连射龙」加入手卡并给对方确认
function c68226653.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足过滤条件的「炎狱连射龙」
	local tc=Duel.GetFirstMatchingCard(c68226653.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将获取到的卡片因效果加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end

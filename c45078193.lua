--サイバー・ダーク・カノン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1只机械族「电子暗黑」怪兽加入手卡。
-- ②：有这张卡装备的怪兽进行战斗的伤害计算时才能发动。从卡组把1只怪兽送去墓地。
-- ③：给怪兽装备的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
function c45078193.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1只机械族「电子暗黑」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45078193,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45078193)
	e1:SetCost(c45078193.cost)
	e1:SetTarget(c45078193.target)
	e1:SetOperation(c45078193.operation)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽进行战斗的伤害计算时才能发动。从卡组把1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45078193,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,45078194)
	e2:SetCondition(c45078193.gycon)
	e2:SetTarget(c45078193.gytg)
	e2:SetOperation(c45078193.gyop)
	c:RegisterEffect(e2)
	-- ③：给怪兽装备的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45078193,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c45078193.con)
	e3:SetTarget(c45078193.tg)
	e3:SetOperation(c45078193.op)
	c:RegisterEffect(e3)
end
-- 检查手卡是否可以丢弃此卡作为发动①的代价
function c45078193.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手卡丢入墓地作为发动①的代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选卡组中满足条件的机械族「电子暗黑」怪兽
function c45078193.filter(c)
	return c:IsSetCard(0x4093) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 设置效果发动时的操作信息，确定将要从卡组检索的卡的类型为加入手牌
function c45078193.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否可以丢弃此卡作为发动①的代价
	if chk==0 then return Duel.IsExistingMatchingCard(c45078193.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动时的操作信息，确定将要从卡组检索的卡的类型为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的发动，选择并把符合条件的卡加入手牌
function c45078193.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local tg=Duel.SelectMatchingCard(tp,c45078193.filter,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤函数，用于筛选卡组中满足条件的怪兽
function c45078193.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 判断装备此卡的怪兽是否参与了战斗
function c45078193.gycon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断装备此卡的怪兽是否参与了战斗
	return ec and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget())
end
-- 设置效果发动时的操作信息，确定将要从卡组送去墓地的卡的类型
function c45078193.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45078193.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动时的操作信息，确定将要从卡组送去墓地的卡的类型
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果的发动，选择并把符合条件的卡送去墓地
function c45078193.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c45078193.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断此卡是否因装备状态被送去墓地
function c45078193.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 设置效果发动时的操作信息，确定将要抽卡的数量
function c45078193.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量
	Duel.SetTargetParam(1)
	-- 设置效果发动时的操作信息，确定将要抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理③效果的发动，执行抽卡操作
function c45078193.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end

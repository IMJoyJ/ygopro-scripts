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
-- ①效果的发动代价：检查手牌中的这张卡是否能够丢弃；可丢弃时将这张卡作为代价从手牌送入墓地。
function c45078193.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以丢弃自身为代价送入墓地（cost）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义检索过滤条件：被检索的卡必须属于机械族、具有「电子暗黑」字段，并且可以加入手卡。
function c45078193.filter(c)
	return c:IsSetCard(0x4093) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- ①效果的发动目标：确认卡组中存在符合条件的机械族「电子暗黑」怪兽，并设置本次处理为从卡组把1张卡加入手卡。
function c45078193.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：卡组中是否存在至少1张满足过滤条件的机械族「电子暗黑」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45078193.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组把1张卡加入持有者手卡（检索动作）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只符合条件的机械族「电子暗黑」怪兽加入手卡，并展示给对方确认。
function c45078193.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让发动者选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 发动者从卡组中选择1张满足c45078193.filter条件的卡片（检索选择）。
	local tg=Duel.SelectMatchingCard(tp,c45078193.filter,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将选中的卡片加入其持有者的手卡（以效果原因）。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 定义②效果用于送去墓地的过滤条件：必须是怪兽卡且可以送去墓地。
function c45078193.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动条件：这张卡作为装备卡所装备的怪兽，正参与本次战斗的伤害计算（是攻击怪兽或被攻击怪兽）。
function c45078193.gycon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判定装备怪兽是否为当前战斗的攻击怪兽或被攻击对象；是则发动条件成立。
	return ec and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget())
end
-- ②效果的目标：检查卡组是否存在可送去墓地的怪兽，并设置从卡组把1只怪兽送去墓地的操作信息。
function c45078193.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：卡组中是否存在至少1只可以送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45078193.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组把1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只满足条件的怪兽送去墓地。
function c45078193.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让发动者选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 发动者从卡组中选择1张满足c45078193.tgfilter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c45078193.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡在作为装备卡装备于怪兽的状态下从魔陷区被送去墓地，且不是因装备对象失去而自动送入墓地（REASON_LOST_TARGET）。
function c45078193.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- ③效果的目标设定：确认发动者能够抽1张卡，并记录抽卡玩家和抽卡数量。
function c45078193.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：玩家tp是否可以抽取1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次效果的对象玩家设定为发动者tp。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的对象参数设定为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本次效果处理包含从卡组抽1张卡的动作。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果处理：实际让之前设定的玩家从卡组抽取1张卡。
function c45078193.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设定的目标玩家和抽卡参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p以效果原因抽d张卡（此处d为1）。
	Duel.Draw(p,d,REASON_EFFECT)
end

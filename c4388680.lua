--リヴェンデット・スレイヤー
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和对方怪兽进行战斗的伤害计算时1次，从自己墓地把1只不死族怪兽除外才能发动。这张卡的攻击力上升300。
-- ②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1张仪式魔法卡加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
function c4388680.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡和对方怪兽进行战斗的伤害计算时1次，从自己墓地把1只不死族怪兽除外才能发动。这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4388680,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c4388680.atkcon)
	e1:SetCost(c4388680.atkcost)
	e1:SetOperation(c4388680.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1张仪式魔法卡加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4388680,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,4388680)
	e2:SetCondition(c4388680.thcon)
	e2:SetTarget(c4388680.thtg)
	e2:SetOperation(c4388680.thop)
	c:RegisterEffect(e2)
end
-- 发动条件判定：判定这张卡正在进行战斗（存在战斗对象），即在和对方怪兽进行战斗的伤害计算时。
function c4388680.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 过滤函数：筛选自己墓地中种族为不死族且可以作为发动代价被除外的怪兽。
function c4388680.atkcfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：先确认墓地存在符合条件的怪兽，然后由玩家选择1只不死族怪兽，将其表侧表示除外作为发动代价。
function c4388680.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 合法性检查：不存在可除外的墓地不死族怪兽时不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4388680.atkcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张满足atkcfilter条件的卡（不死族怪兽）。
	local g=Duel.SelectMatchingCard(tp,c4388680.atkcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若这张卡仍与效果相关且处于表侧表示，则给它注册一个攻击力上升300的效果。
function c4388680.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 触发条件判定：这张卡之前存在于主要怪兽区（从场上）被送去墓地，并且是仪式召唤过的怪兽。
function c4388680.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：筛选卡组中类型为仪式魔法（仪式+魔法）且可以加入手卡的卡。
function c4388680.thfilter(c)
	return c:GetType()==TYPE_RITUAL+TYPE_SPELL and c:IsAbleToHand()
end
-- 过滤函数：筛选卡组中类型为怪兽、属于「复仇死者」字段且可以送去墓地的卡。
function c4388680.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106) and c:IsAbleToGrave()
end
-- 效果发动时合法性判定：卡组中同时存在符合条件的仪式魔法卡和「复仇死者」怪兽卡才能发动。
function c4388680.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张可加入手卡的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4388680.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 同时检查卡组中是否存在1只可送去墓地的「复仇死者」怪兽。
		and Duel.IsExistingMatchingCard(c4388680.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理包含将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次处理包含将1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先从卡组选择1张仪式魔法卡加入手卡，并让对方确认；确认成功后再从卡组选择1只「复仇死者」怪兽送去墓地。
function c4388680.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，要求选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足thfilter条件的仪式魔法卡。
	local hg=Duel.SelectMatchingCard(tp,c4388680.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断仪式魔法卡是否成功加入手卡：选择的卡不为空、送入手卡成功且该卡确实在手卡区域。
	if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0
		and hg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将加入手卡的仪式魔法卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,hg)
		-- 向玩家发送提示，要求选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从卡组选择1张满足tgfilter条件的「复仇死者」怪兽。
		local g=Duel.SelectMatchingCard(tp,c4388680.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「复仇死者」怪兽送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

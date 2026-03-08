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
	-- ②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1张仪式魔法卡加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
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
-- 判断是否处于战斗状态，即是否有对方怪兽作为攻击目标。
function c4388680.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 过滤满足条件的不死族怪兽（可作为除外的代价）。
function c4388680.atkcfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的不死族怪兽可除外，并选择其中一张进行除外操作。
function c4388680.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的不死族怪兽可除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c4388680.atkcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的不死族怪兽进行除外。
	local g=Duel.SelectMatchingCard(tp,c4388680.atkcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置攻击力上升300的效果。
function c4388680.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置攻击力上升300的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否为仪式召唤且从主要怪兽区被送去墓地。
function c4388680.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤满足条件的仪式魔法卡（可加入手牌）。
function c4388680.thfilter(c)
	return c:GetType()==TYPE_RITUAL+TYPE_SPELL and c:IsAbleToHand()
end
-- 过滤满足条件的「复仇死者」怪兽（可送去墓地）。
function c4388680.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106) and c:IsAbleToGrave()
end
-- 检查是否同时存在满足条件的仪式魔法卡和「复仇死者」怪兽。
function c4388680.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4388680.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查是否存在满足条件的「复仇死者」怪兽。
		and Duel.IsExistingMatchingCard(c4388680.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张仪式魔法卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从卡组将1只「复仇死者」怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并处理效果：选择仪式魔法卡加入手牌，再选择「复仇死者」怪兽送去墓地。
function c4388680.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的仪式魔法卡加入手牌。
	local hg=Duel.SelectMatchingCard(tp,c4388680.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的卡已成功加入手牌。
	if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0
		and hg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认已加入手牌的卡。
		Duel.ConfirmCards(1-tp,hg)
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的「复仇死者」怪兽送去墓地。
		local g=Duel.SelectMatchingCard(tp,c4388680.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「复仇死者」怪兽送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

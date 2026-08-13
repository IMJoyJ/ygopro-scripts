--プロフィビット・スネーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的电子界族连接怪兽和对方怪兽进行战斗的伤害步骤开始时，把这张卡从手卡送去墓地才能发动。那只对方怪兽回到持有者手卡。
-- ②：这张卡在墓地存在，自己的电子界族怪兽战斗破坏对方怪兽送去墓地时，从自己墓地把1张卡除外，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽加入手卡。
function c39732186.initial_effect(c)
	-- ①：自己的电子界族连接怪兽和对方怪兽进行战斗的伤害步骤开始时，把这张卡从手卡送去墓地才能发动。那只对方怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39732186,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39732186)
	e1:SetCondition(c39732186.thcon)
	e1:SetCost(c39732186.thcost)
	e1:SetTarget(c39732186.thtg)
	e1:SetOperation(c39732186.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己的电子界族怪兽战斗破坏对方怪兽送去墓地时，从自己墓地把1张卡除外，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39732186,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39732187)
	e2:SetCondition(c39732186.thcon2)
	e2:SetCost(c39732186.thcost2)
	e2:SetTarget(c39732186.thtg2)
	e2:SetOperation(c39732186.thop2)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：取得本次战斗的攻击怪兽和被攻击怪兽，若攻击方是对方则交换，使tc为发动方的电子界族连接怪兽、bc为对方怪兽；将bc保存到LabelObject，并判定tc为表侧表示且属于电子界族连接怪兽。
function c39732186.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽。
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	e:SetLabelObject(bc)
	return tc:IsFaceup() and tc:IsRace(RACE_CYBERSE) and tc:IsType(TYPE_LINK)
end
-- ①效果发动代价：检查这张卡能否从手卡作为代价送去墓地，若能则支付。
function c39732186.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果发动时确认：取回之前保存的对方怪兽，检查其可以加入手牌，并设定将其回手牌的操作信息。
function c39732186.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsAbleToHand() end
	-- 设定连锁处理时将对方怪兽回到持有者手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,bc,1,0,0)
end
-- ①效果处理：若之前保存的对方怪兽仍与本次战斗相关且仍由对方控制，则将其送回持有者手卡。
function c39732186.thop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将那只对方怪兽因效果返回持有者手卡。
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
-- ②效果发动条件：确认被战斗破坏送去墓地的只有对方1只怪兽，且它是被自己的电子界族怪兽战斗破坏，该电子界族怪兽仍与战斗相关。
function c39732186.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1	and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and bc:IsRelateToBattle() and bc:IsControler(tp) and bc:IsRace(RACE_CYBERSE)
end
-- 代价选择过滤：判定该卡可作为除外代价，并且自己墓地还存在至少1只满足加入手牌条件的4星以下电子界族怪兽。
function c39732186.cfilter(c,tp)
	-- 返回该卡可作为代价除外，且墓地存在满足条件的电子界族对象（排除该代价卡）。
	return c:IsAbleToRemoveAsCost() and Duel.IsExistingTarget(c39732186.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- ②效果对象过滤：等级4以下的电子界族怪兽且可以被加入手牌。
function c39732186.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- ②效果发动代价：确认自己墓地存在可除外且能保证有对象可选的卡，让玩家选择1张除外作为代价。
function c39732186.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1张可作为代价除外的卡且同时存在可加入手牌的对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c39732186.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家提示选择要除外的卡（发送选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的卡作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c39732186.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的卡表侧除外，作为②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果目标处理：选择自己墓地1只4星以下电子界族怪兽作为对象，并设定将其加入手牌的操作信息。
function c39732186.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39732186.thfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择要加入手牌的卡（发送选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1只满足条件的电子界族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c39732186.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设定将选择的对象卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若对象仍与效果关联，则将其加入持有者手卡。
function c39732186.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡因效果返回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

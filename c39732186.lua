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
-- 判断是否满足效果①的发动条件：确认攻击怪兽为电子界族连接怪兽
function c39732186.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取当前战斗的防守怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	e:SetLabelObject(bc)
	return tc:IsFaceup() and tc:IsRace(RACE_CYBERSE) and tc:IsType(TYPE_LINK)
end
-- 效果①的发动费用：将此卡送去墓地
function c39732186.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手牌送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果①的发动宣言：将对方怪兽送回手牌
function c39732186.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsAbleToHand() end
	-- 设置连锁操作信息，指定将防守怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,bc,1,0,0)
end
-- 效果①的处理：将防守怪兽送回手牌
function c39732186.thop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将防守怪兽送回手牌
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
-- 判断是否满足效果②的发动条件：确认被战斗破坏的怪兽为己方电子界族怪兽
function c39732186.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1	and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and bc:IsRelateToBattle() and bc:IsControler(tp) and bc:IsRace(RACE_CYBERSE)
end
-- 过滤函数：检查墓地是否存在可除外的卡并能选择目标怪兽
function c39732186.cfilter(c,tp)
	-- 检查墓地是否存在可除外的卡并能选择目标怪兽
	return c:IsAbleToRemoveAsCost() and Duel.IsExistingTarget(c39732186.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- 过滤函数：选择墓地4星以下的电子界族怪兽
function c39732186.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- 效果②的发动费用：从墓地除外1张卡
function c39732186.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果②的发动费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c39732186.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张可除外的卡
	local g=Duel.SelectMatchingCard(tp,c39732186.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动宣言：选择1只4星以下的电子界族怪兽加入手牌
function c39732186.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39732186.thfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只4星以下的电子界族怪兽
	local g=Duel.SelectTarget(tp,c39732186.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：将目标怪兽送回手牌
function c39732186.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

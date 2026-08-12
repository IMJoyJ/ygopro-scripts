--エレファン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以选择从游戏中除外的1只自己的3星以下的兽族·兽战士族·鸟兽族怪兽加入手卡。
function c88845345.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以选择从游戏中除外的1只自己的3星以下的兽族·兽战士族·鸟兽族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88845345,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c88845345.condition)
	e1:SetTarget(c88845345.target)
	e1:SetOperation(c88845345.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身因战斗破坏被送去墓地。
function c88845345.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：表侧表示、等级3以下、兽族/兽战士族/鸟兽族且能加入手牌的怪兽。
function c88845345.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与处理：检查是否存在符合条件的目标，并进行取对象选择，设置操作信息。
function c88845345.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c88845345.filter(chkc) end
	-- 在效果发动阶段（chk==0），检查除外区是否存在至少1只符合条件的自己怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c88845345.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择除外区1只符合条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c88845345.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：获取选中的对象，若其仍符合条件，则将其加入手牌并向对方展示。
function c88845345.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end

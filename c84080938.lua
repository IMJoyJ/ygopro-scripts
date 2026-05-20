--慈悲深き修道女
-- 效果：
-- 表侧表示的这张卡做祭品。这个回合被战斗破坏送去墓地的1只自己的怪兽回手卡。
function c84080938.initial_effect(c)
	-- 表侧表示的这张卡做祭品。这个回合被战斗破坏送去墓地的1只自己的怪兽回手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c84080938.cost)
	e1:SetTarget(c84080938.target)
	e1:SetOperation(c84080938.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价，检查并解放自身
function c84080938.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤出本回合被战斗破坏送去墓地且能加入手牌的怪兽
function c84080938.filter(c,tid)
	return c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsAbleToHand()
end
-- 定义效果发动的目标，获取当前回合数并选择墓地中1只符合条件的怪兽作为对象
function c84080938.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84080938.filter(chkc,tid) end
	-- 在效果发动时，检查自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c84080938.filter,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 向玩家发送提示信息，要求选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地中1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84080938.filter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置效果处理的操作信息为将选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理，将选中的效果对象怪兽加入手牌并给对方确认
function c84080938.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认送回手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end

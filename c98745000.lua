--ジャッカルの聖戦士
-- 效果：
-- 这张卡战斗破坏对方场上1只怪兽并将送其进墓地时，可以把那张卡放回对方卡组最上面。
function c98745000.initial_effect(c)
	-- 这张卡战斗破坏对方场上1只怪兽并将送其进墓地时，可以把那张卡放回对方卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98745000,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c98745000.tdcon)
	e1:SetTarget(c98745000.tdtg)
	e1:SetOperation(c98745000.tdop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：自身在战斗中且表侧表示，且被战斗破坏的怪兽是对方怪兽并已送去墓地
function c98745000.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp)
end
-- 判断效果发动目标：被战斗破坏的怪兽是否能送回卡组，并进行对象确认和操作信息注册
function c98745000.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsAbleToDeck() end
	-- 将被战斗破坏的怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(bc)
	-- 设置当前连锁的操作信息为：将1张目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,bc,1,0,0)
end
-- 执行效果处理：获取目标怪兽，若其仍与效果关联，则将其送回持有者卡组最上方
function c98745000.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽送回其持有者的卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

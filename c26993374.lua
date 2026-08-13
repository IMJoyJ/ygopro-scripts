--X－セイバー ウルズ
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡解放，破坏的卡回到持有者卡组最上面。
function c26993374.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡解放，破坏的卡回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26993374,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c26993374.tdcon)
	e1:SetCost(c26993374.tdcost)
	e1:SetTarget(c26993374.tdtg)
	e1:SetOperation(c26993374.tdop)
	c:RegisterEffect(e1)
end
-- 设置发动条件：获取与该卡战斗的对方怪兽并保存在效果标签中，同时调用公共条件函数确认满足“战斗破坏对方怪兽送去墓地”的时点。
function c26993374.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 调用公共条件函数aux.bdogcon，判断效果持有者是否与对方怪兽战斗并将其战斗破坏送入墓地，返回值作为触发条件的判定结果。
	return aux.bdogcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 设置发动代价：确认此卡可以被解放后，将此卡解放作为效果发动的代价。
function c26993374.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡以代价（REASON_COST）解放，从场上送去墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标处理：确认被战斗破坏并保存的对方怪兽可以返回卡组，使其与效果建立关联，并登记此次将进行的回卡组操作。
function c26993374.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local t=e:GetLabelObject()
	if chk==0 then return t:IsAbleToDeck() end
	t:CreateEffectRelation(e)
	-- 登记操作信息：将之前保存的被战斗破坏的对方怪兽作为对象，设置本次连锁将执行1次返回卡组（CATEGORY_TODECK）的处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,t,1,0,0)
end
-- 效果处理：确认目标怪兽仍与该效果存在关联后，将其送回持有者卡组最上面。
function c26993374.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以效果原因（REASON_EFFECT）送回到持有者卡组最顶端（SEQ_DECKTOP）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

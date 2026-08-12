--X－セイバー ウルズ
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡解放，破坏的卡回到持有者卡组最上面。
function c26993374.initial_effect(c)
	-- 创建效果，设置效果描述为“返回卡组”，设置效果分类为回卡组，设置触发事件为战斗破坏，设置效果类型为单体诱发效果，设置条件函数为tdcon，设置费用函数为tdcost，设置目标函数为tdtg，设置效果处理函数为tdop
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
-- 判断是否与对方怪兽战斗并战斗破坏对方怪兽送去墓地
function c26993374.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 调用辅助函数检测是否满足战斗破坏条件
	return aux.bdogcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 检查是否可以解放自身作为效果的费用
function c26993374.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放自身的效果费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检查破坏的怪兽是否可以送回卡组，设置操作信息为回卡组
function c26993374.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local t=e:GetLabelObject()
	if chk==0 then return t:IsAbleToDeck() end
	t:CreateEffectRelation(e)
	-- 设置连锁操作信息，指定回卡组效果的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,t,1,0,0)
end
-- 执行效果处理，将破坏的怪兽送回卡组最上面
function c26993374.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

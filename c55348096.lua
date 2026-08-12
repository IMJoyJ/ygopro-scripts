--武器庫荒らし
-- 效果：
-- 对方从卡组里选择1张装备魔法卡送去墓地。
function c55348096.initial_effect(c)
	-- 对方从卡组里选择1张装备魔法卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55348096.target)
	e1:SetOperation(c55348096.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选卡组中可以送去墓地的装备魔法卡
function c55348096.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- 效果发动的目标选择与检测函数
function c55348096.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方卡组中是否存在卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 设置操作信息：对方卡组有1张卡要送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c55348096.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让对方玩家从其卡组中选择1张装备魔法卡
	local g=Duel.SelectMatchingCard(1-tp,c55348096.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

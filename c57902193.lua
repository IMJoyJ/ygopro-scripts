--苦渋の転生
-- 效果：
-- 从自己墓地由对方选1只怪兽。这个回合的结束阶段时，那只怪兽从墓地加入自己手卡。
function c57902193.initial_effect(c)
	-- 从自己墓地由对方选1只怪兽。这个回合的结束阶段时，那只怪兽从墓地加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(c57902193.target)
	e1:SetOperation(c57902193.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以加入手牌的怪兽卡
function c57902193.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的靶向与合法性检测
function c57902193.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以加入手牌的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57902193.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为将自己墓地的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：让对方从自己墓地选择1只怪兽，并为其注册在结束阶段加入手牌的效果
function c57902193.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由对方玩家从自己墓地选择1只怪兽
	local g=Duel.SelectMatchingCard(1-tp,c57902193.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 这个回合的结束阶段时，那只怪兽从墓地加入自己手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1)
		e1:SetOperation(c57902193.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 结束阶段时将目标怪兽加入手牌并给对方确认的具体处理
function c57902193.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽加入手牌
	if Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)~=0 then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end

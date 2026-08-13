--ジュラック・プティラ
-- 效果：
-- 这张卡被攻击的场合，伤害计算后攻击怪兽回到手卡。这张卡的守备力上升这个效果回到手卡的怪兽等级×100的数值。
function c45711266.initial_effect(c)
	-- 这张卡被攻击的场合，伤害计算后攻击怪兽回到手卡。这张卡的守备力上升这个效果回到手卡的怪兽等级×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45711266,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c45711266.condition)
	e1:SetTarget(c45711266.target)
	e1:SetOperation(c45711266.operation)
	c:RegisterEffect(e1)
end
-- 诱发条件判定：效果拥有者必须是此次战斗的攻击目标（即这张卡被攻击），条件满足时效果才可以发动。
function c45711266.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果拥有者是否为当前战斗的攻击目标，若是则条件成立。
	return e:GetHandler()==Duel.GetAttackTarget()
end
-- 发动时的目标处理：无需选择对象，直接登记将攻击怪兽加入手卡的操作信息。
function c45711266.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取此次战斗的攻击怪兽，作为即将回手牌的对象。
	local tc=Duel.GetAttacker()
	-- 登记效果处理时把攻击怪兽加入手牌的操作信息，分类为回手牌，对象为攻击怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 效果处理：将攻击怪兽回手牌；若这张卡没有被战斗破坏，则再使其守备力上升该怪兽等级×100的数值。
function c45711266.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽，用于后续判定和处理。
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() then
		local lv=tc:GetLevel()
		-- 以效果原因将攻击怪兽送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		if not c:IsStatus(STATUS_BATTLE_DESTROYED) then
			-- 这张卡的守备力上升这个效果回到手卡的怪兽等级×100的数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(lv*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end

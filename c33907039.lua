--ピリ・レイスの地図
-- 效果：
-- ①：自己主要阶段1开始时才能发动。从卡组把1只攻击力0的怪兽加入手卡，自己基本分变成一半。这张卡的发动后，直到下个回合的结束时，自己只要这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，不能把那只怪兽以及那些同名卡的效果发动。
function c33907039.initial_effect(c)
	-- ①：自己主要阶段1开始时才能发动。从卡组把1只攻击力0的怪兽加入手卡，自己基本分变成一半。这张卡的发动后，直到下个回合的结束时，自己只要这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，不能把那只怪兽以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c33907039.condition)
	e1:SetTarget(c33907039.target)
	e1:SetOperation(c33907039.activate)
	c:RegisterEffect(e1)
end
-- 检查是否处于主要阶段1开始时
function c33907039.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1且未进行过阶段活动
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 过滤函数，用于筛选攻击力为0的怪兽
function c33907039.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsAbleToHand()
end
-- 设置效果处理时需要检索的卡组中的怪兽
function c33907039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33907039.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果：选择并检索攻击力为0的怪兽加入手牌，确认对方查看，将LP减半，并设置后续限制效果
function c33907039.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只攻击力为0的怪兽
	local g=Duel.SelectMatchingCard(tp,c33907039.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的怪兽成功加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认查看所选怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 将玩家LP设置为原来的一半
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 设置效果限制：当同名怪兽召唤不成功时，不能发动其效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c33907039.aclimit)
			e1:SetLabel(g:GetFirst():GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 注册限制效果到玩家场上
			Duel.RegisterEffect(e1,tp)
			-- 设置持续效果：当同名怪兽召唤成功时，清除限制效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_SUMMON_SUCCESS)
			e2:SetOperation(c33907039.regop)
			e2:SetLabelObject(e1)
			e2:SetLabel(g:GetFirst():GetCode())
			e2:SetReset(RESET_PHASE+PHASE_END,2)
			-- 注册持续效果到玩家场上
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 限制效果的判断函数，判断是否为同名卡
function c33907039.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 持续效果的处理函数，当同名怪兽召唤成功时清除限制效果
function c33907039.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonPlayer(tp) and tc:IsCode(e:GetLabel()) then
		e:GetLabelObject():Reset()
		e:Reset()
	end
end

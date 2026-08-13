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
-- 发动条件判定函数：确认当前为自己的主要阶段1开始时（尚未进行任何操作），满足“自己主要阶段1开始时才能发动”的时机限制。
function c33907039.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是主要阶段1且本阶段尚无其他操作，以此锁定“主要阶段1开始时”这一特定时点。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 过滤函数：从卡组中筛选出攻击力为0、且能够加入手卡的怪兽卡。
function c33907039.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsAbleToHand()
end
-- 发动时的目标检查与操作信息设置：确认卡组中存在符合条件的攻击力0怪兽，并宣告将执行“从卡组检索并加入手卡”的操作。
function c33907039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查卡组是否有至少1只满足条件的攻击力0怪兽，若没有则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33907039.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：处理时将从卡组把1张卡加入手卡（检索类效果），供后续的时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择1只攻击力0怪兽加入手卡、展示给对手、基本分减半，并在满足条件时施加“该怪兽及其同名卡在召唤成功前不能发动效果”的限制。
function c33907039.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示己方从卡组选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组精确选择1张满足条件的攻击力0怪兽。
	local g=Duel.SelectMatchingCard(tp,c33907039.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选到卡且成功加入手卡，并确认该卡确实已加入手牌后，才继续执行后续的确认、变更LP和施加限制处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将加入手卡的怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 将己方基本分减半，数值向上取整。
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 这张卡的发动后，直到下个回合的结束时，自己只要这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，不能把那只怪兽以及那些同名卡的效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c33907039.aclimit)
			e1:SetLabel(g:GetFirst():GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 将禁发效果e1注册到场上，使其持续作用于己方玩家（下个回合结束时重置）。
			Duel.RegisterEffect(e1,tp)
			-- 自己只要这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，不能把那只怪兽以及那些同名卡的效果发动（通过监听召唤成功来解除该限制）。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_SUMMON_SUCCESS)
			e2:SetOperation(c33907039.regop)
			e2:SetLabelObject(e1)
			e2:SetLabel(g:GetFirst():GetCode())
			e2:SetReset(RESET_PHASE+PHASE_END,2)
			-- 将召唤成功监听效果e2注册到场上，用于检测己方是否成功召唤了加入手卡的怪兽或其同名卡。
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 禁发判定函数：如果试图发动的效果的来源卡卡号与加入手卡怪兽的卡号相同，则该效果不能发动。
function c33907039.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 召唤成功监听处理：当己方成功召唤了加入手卡的怪兽或其同名卡时，重置禁发效果和监听效果，解除后续的发动限制。
function c33907039.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonPlayer(tp) and tc:IsCode(e:GetLabel()) then
		e:GetLabelObject():Reset()
		e:Reset()
	end
end

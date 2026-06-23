--幾星霜
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽被自己的魔法卡的效果或者对方的效果破坏送去墓地的回合才能发动。下次的自己战斗阶段可以进行2次。
-- ②：这张卡在墓地存在的状态，自己场上的怪兽回到卡组·额外卡组（里侧）的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡的效果，包括①效果的发动条件和处理函数
function s.initial_effect(c)
	-- ①：自己场上的怪兽被自己的魔法卡的效果或者对方的效果破坏送去墓地的回合才能发动。下次的自己战斗阶段可以进行2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.conditon)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的怪兽回到卡组·额外卡组（里侧）的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 当怪兽被破坏时，若其为己方怪兽且破坏原因为效果，则为破坏者注册标识效果，用于记录①效果的触发条件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.descheck)
		-- 将全局持续效果注册到玩家0（即双方）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历被破坏的卡片组，检查是否满足①效果的触发条件
function s.descheck(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历被破坏的卡片组，检查是否满足①效果的触发条件
	for tc in aux.Next(eg) do
		-- 若卡片在怪兽区域被破坏且破坏原因为效果，且该玩家未注册过此标识效果，则继续判断
		if tc:IsLocation(LOCATION_MZONE) and r&REASON_EFFECT>0 and Duel.GetFlagEffect(tc:GetControler(),id)==0 then
			if re~=nil and re:GetHandler():IsType(TYPE_SPELL) or tc:GetReasonPlayer()==1-tc:GetControler() then
				-- 若破坏来源为魔法卡或破坏者为对方，则为该玩家注册标识效果，用于记录①效果的触发条件
				Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- 判断是否满足①效果的发动条件
function s.conditon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该玩家是否已注册过标识效果
	return Duel.GetFlagEffect(tp,id)>0
end
-- 注册①效果，使下次战斗阶段可以进行2次
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 设置①效果的触发条件和重置方式
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前是否为己方回合且处于战斗阶段
	if Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 记录当前回合数，用于判断是否为同一回合
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	end
	-- 将①效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置①效果的触发条件，判断是否为不同回合
function s.bpcon(e)
	-- 判断当前回合数是否与记录的回合数不同
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 定义用于判断是否满足②效果发动条件的过滤器函数
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and (c:IsFacedown() or c:IsLocation(LOCATION_DECK))
end
-- 判断是否满足②效果的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置②效果的目标和处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，表示将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理②效果的发动，将卡加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对手看到该卡
		Duel.ConfirmCards(1-tp,c)
	end
end

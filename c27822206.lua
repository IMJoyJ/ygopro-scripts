--幾星霜
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽被自己的魔法卡的效果或者对方的效果破坏送去墓地的回合才能发动。下次的自己战斗阶段可以进行2次。
-- ②：这张卡在墓地存在的状态，自己场上的怪兽回到卡组·额外卡组（里侧）的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册①效果的魔法卡发动效果、②效果的墓地诱发效果，以及一个全场破坏检测效果：e1在满足条件时发动并给予下次战斗阶段两次战斗；e2在怪兽回卡组/额外卡组（里侧）时回收自身；ge1记录本回合被效果破坏的怪兽所属玩家标记。
function s.initial_effect(c)
	-- ①：自己场上的怪兽被自己的魔法卡的效果或者对方的效果破坏送去墓地的回合才能发动。下次的自己战斗阶段可以进行2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.conditon)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己场上的怪兽回到卡组·额外卡组（里侧）的场合才能发动。这张卡加入手卡。
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
		-- ①：自己场上的怪兽被自己的魔法卡的效果或者对方的效果破坏送去墓地的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.descheck)
		-- 将全局破坏检测效果ge1注册到全场，持续监视场上怪兽被效果破坏的事件，用于为符合条件的控制者登记标记。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 处理破坏事件：遍历被破坏的怪兽，若其之前位于怪兽区且是被效果破坏、对应控制者尚无标记，且破坏来源是自己的魔法卡效果或对方的效果，则给该控制者设置一个结束后重置的标记。
function s.descheck(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历本次破坏事件涉及的所有卡片。
	for tc in aux.Next(eg) do
		-- 判断被破坏的怪兽是否在怪兽区、是否因效果破坏、且该控制者尚未获得相关标记，以确定是否满足①的触发条件。
		if tc:IsLocation(LOCATION_MZONE) and r&REASON_EFFECT>0 and Duel.GetFlagEffect(tc:GetControler(),id)==0 then
			if re~=nil and re:GetHandler():IsType(TYPE_SPELL) or tc:GetReasonPlayer()==1-tc:GetControler() then
				-- 为该怪兽的控制者注册一个id标记，持续到结束阶段，表示本回合已有符合条件的怪兽被效果破坏。
				Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- ①效果的发动条件：检查本回合是否已记录到符合条件的破坏（有标记），有则允许发动。
function s.conditon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家tp是否含有id标记（即本回合是否满足①的发动条件）。
	return Duel.GetFlagEffect(tp,id)>0
end
-- ①效果处理：为tp玩家注册一个‘战斗阶段可以进行2次’的效果，并设定只在下次自己的战斗阶段适用；若发动时已在自己战斗阶段内，则跳过当前战斗阶段，延后到下一次自己的战斗阶段。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的自己战斗阶段可以进行2次。②：这张卡在墓地存在的状态，自己场上的怪兽回到卡组·额外卡组（里侧）的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断发动时是否处于自己的战斗阶段内（从战斗阶段开始到战斗阶段结束），以决定‘2次战斗阶段’效果的持续方式。
	if Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 将当前回合数保存到效果e1的label中，用于避免在当前战斗阶段内立即适用‘2次战斗阶段’效果。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	end
	-- 将‘可以进行2次战斗阶段’的效果e1注册给玩家tp，使效果开始生效。
	Duel.RegisterEffect(e1,tp)
end
-- ‘2次战斗阶段’效果的适用条件：当前回合数不等于发动时的回合数，确保只在下次自己的战斗阶段适用。
function s.bpcon(e)
	-- 判断当前回合数是否与e1记录的发动时回合数不同，以延迟效果的适用时点。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 定义②效果的触发过滤条件：事件中的卡必须是之前由tp控制、原位于主要怪兽区的怪兽，且最终以里侧表示回到卡组/额外卡组（用IsFacedown或位于卡组来判断）。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and (c:IsFacedown() or c:IsLocation(LOCATION_DECK))
end
-- ②效果的触发条件：本次回到卡组/额外卡组的事件中，存在至少1只‘自己场上的怪兽回到卡组·额外卡组（里侧）’的怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动目标：确认墓地的这张卡可以加入手卡，并设置操作信息，准备将这张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置本连锁的操作信息为“回收这张卡到持有者手卡”（CATEGORY_TOHAND），供效果处理及相关时点判断使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联（未被移动），则将其从墓地加入手卡，并向对手确认该卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的‘几星霜’以效果原因加入其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对手玩家确认被加入手卡的‘几星霜’，使对方知晓该卡。
		Duel.ConfirmCards(1-tp,c)
	end
end

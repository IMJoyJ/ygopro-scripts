--燃え竹光
-- 效果：
-- ①：这张卡已在魔法与陷阱区域存在的状态，自己把「竹光」卡发动的场合才能发动。下次的对方主要阶段1跳过。
function c55870497.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡已在魔法与陷阱区域存在的状态，自己把「竹光」卡发动的场合才能发动。下次的对方主要阶段1跳过。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55870497,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c55870497.skipcon)
	e3:SetTarget(c55870497.skiptg)
	e3:SetOperation(c55870497.skipop)
	c:RegisterEffect(e3)
end
-- 检查触发条件是否为自己发动了「竹光」卡片的效果
function c55870497.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandler():IsSetCard(0x60)
end
-- 效果发动的靶向与可行性检测，确认对方未被施加跳过主要阶段1的效果
function c55870497.skiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，确认对方玩家当前没有被施加跳过主要阶段1的效果
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_M1) end
end
-- 效果处理，注册一个使对方玩家跳过下一个主要阶段1的全局效果，并根据当前回合玩家处理时效
function c55870497.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方主要阶段1跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_M1)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前回合玩家是否已经是对方玩家
	if Duel.GetTurnPlayer()==1-tp then
		-- 将当前回合数记录在效果的Label中，用于后续判断是否是“下次”的对方回合
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c55870497.turncon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	-- 将跳过主要阶段1的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制跳过效果在当前回合不生效，确保在“下次”对方回合才生效
function c55870497.turncon(e)
	-- 当且仅当当前回合数不等于发动效果时的回合数时，该跳过效果才生效
	return Duel.GetTurnCount()~=e:GetLabel()
end

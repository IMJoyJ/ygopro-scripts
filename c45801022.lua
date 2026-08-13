--エレキツネザル
-- 效果：
-- 这张卡被对方破坏的场合，下次的对方回合，对方不能进行战斗阶段。
function c45801022.initial_effect(c)
	-- 这张卡被对方破坏的场合，下次的对方回合，对方不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45801022,0))  --"对方不能进行战斗阶段"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c45801022.condition)
	e1:SetOperation(c45801022.operation)
	c:RegisterEffect(e1)
end
-- 仅当此卡被对方破坏且破坏前控制者为这张卡的原控制者时条件成立，对应“这张卡被对方破坏”的场合。
function c45801022.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 将“对方不能进行战斗阶段”的效果注册到场上，并依据发动时的回合情况设置持续时间，使禁令在下次对方回合生效。
function c45801022.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合，对方不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c45801022.con)
	-- 记录当前的回合数，用于标记效果应从哪一个回合开始适用。
	e1:SetLabel(Duel.GetTurnCount())
	-- 如果当前是这张卡的控制者的回合，则按一个对方回合的时长重置；否则按两个回合阶段重置，用于确保效果持续到下一个对方回合。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 将禁止战斗阶段的效果注册到游戏中，使其对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 效果适用的条件：当前回合数不等于效果记录时的回合数，即只在效果被破坏之后的下一个对方回合适用，避免当回合立即生效。
function c45801022.con(e)
	-- 判断当前回合数是否已不同于初始记录，若不同则允许禁止战斗阶段的效果适用。
	return Duel.GetTurnCount()~=e:GetLabel()
end

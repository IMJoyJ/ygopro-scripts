--エレキツネザル
-- 效果：
-- 这张卡被对方破坏的场合，下次的对方回合，对方不能进行战斗阶段。
function c45801022.initial_effect(c)
	-- 对方不能进行战斗阶段
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45801022,0))  --"对方不能进行战斗阶段"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c45801022.condition)
	e1:SetOperation(c45801022.operation)
	c:RegisterEffect(e1)
end
-- 判断是否为对方破坏且破坏时控制者为对方
function c45801022.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 创建并注册一个影响对方的不能战斗阶段效果
function c45801022.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方不能进行战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c45801022.con)
	-- 记录当前回合数用于后续判断
	e1:SetLabel(Duel.GetTurnCount())
	-- 判断当前回合是否为己方回合
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 将效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为对方破坏且破坏时控制者为对方
function c45801022.con(e)
	-- 当回合数不等于记录的回合数时效果生效
	return Duel.GetTurnCount()~=e:GetLabel()
end

--リンク・バンパー
-- 效果：
-- 电子界族怪兽2只
-- ①：1回合1次，这张卡所连接区的自己怪兽向对方的连接怪兽攻击的伤害步骤结束时才能发动。这次战斗阶段中，那只怪兽在通常攻击外加上可以向对方的连接怪兽作出最多有这张卡以外的自己场上的连接怪兽数量的攻击。这个效果发动的回合，那只怪兽以外的自己怪兽不能攻击。
function c67231737.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- ①：1回合1次，这张卡所连接区的自己怪兽向对方的连接怪兽攻击的伤害步骤结束时才能发动。这次战斗阶段中，那只怪兽在通常攻击外加上可以向对方的连接怪兽作出最多有这张卡以外的自己场上的连接怪兽数量的攻击。这个效果发动的回合，那只怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67231737,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c67231737.condition)
	e1:SetCost(c67231737.cost)
	e1:SetTarget(c67231737.target)
	e1:SetOperation(c67231737.operation)
	c:RegisterEffect(e1)
end
-- 过滤发动条件：伤害步骤结束时，攻击怪兽是这张卡所连接区的自己怪兽，且攻击对象是对方的连接怪兽
function c67231737.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	if a:IsControler(1-tp) then return false end
	local lg=e:GetHandler():GetLinkedGroup()
	local d=a:GetBattleTarget()
	return lg:IsContains(a) and d and d:IsControler(1-tp)
end
-- 过滤已进行过攻击宣言的怪兽
function c67231737.oathfilter(c)
	return c:GetAttackAnnouncedCount()>0
end
-- 过滤发动代价：检查本回合是否有其他怪兽进行过攻击，并注册“那只怪兽以外的自己怪兽不能攻击”的效果
function c67231737.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	local c=e:GetHandler()
	-- 检查在自己场上是否存在除当前攻击怪兽以外、且本回合已进行过攻击宣言的怪兽（若有则不能发动）
	if chk==0 then return not Duel.IsExistingMatchingCard(c67231737.oathfilter,tp,LOCATION_MZONE,0,1,a) end
	-- 这个效果发动的回合，那只怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c67231737.ftarget)
	e1:SetLabel(a:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能攻击的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤不能攻击的怪兽（排除当前进行攻击的怪兽）
function c67231737.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 过滤效果发动时的目标：检查自己场上是否存在除这张卡以外的连接怪兽
function c67231737.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的连接怪兽
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,e:GetHandler(),TYPE_LINK)>0 end
end
-- 效果处理：计算自己场上除这张卡以外的连接怪兽数量，并赋予攻击怪兽追加攻击和限制攻击对象的效果
function c67231737.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算自己场上除这张卡以外的连接怪兽的数量
	local gc=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e),TYPE_LINK)
	if gc==0 then return end
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	if a:IsRelateToBattle() and a:IsFaceup() then
		-- 这次战斗阶段中，那只怪兽在通常攻击外加上可以向对方的连接怪兽作出最多有这张卡以外的自己场上的连接怪兽数量的攻击。
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e0:SetValue(gc)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		a:RegisterEffect(e0)
		-- 可以向对方的连接怪兽作出最多有这张卡以外的自己场上的连接怪兽数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetValue(c67231737.atklimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		a:RegisterEffect(e1)
	end
end
-- 限制攻击对象不能是非连接怪兽（即只能向连接怪兽攻击）
function c67231737.atklimit(e,c)
	return not c:IsType(TYPE_LINK)
end

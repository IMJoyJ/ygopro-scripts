--変則ギア
-- 效果：
-- ①：自己怪兽和对方怪兽进行战斗的伤害计算时才能发动。和对方玩家进行猜拳。平局的场合重新猜拳。输的玩家必须把那只进行战斗的自身怪兽里侧表示除外。
function c58297729.initial_effect(c)
	-- ①：自己怪兽和对方怪兽进行战斗的伤害计算时才能发动。和对方玩家进行猜拳。平局的场合重新猜拳。输的玩家必须把那只进行战斗的自身怪兽里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetTarget(c58297729.target)
	e1:SetOperation(c58297729.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与条件：必须在有攻击对象且双方怪兽控制者不同，且两只怪兽都能被其控制者以规则原因里侧表示除外时才能发动
function c58297729.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取此次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and a:GetControler()~=d:GetControler()
		and a:IsAbleToRemove(a:GetControler(),POS_FACEDOWN,REASON_RULE) and d:IsAbleToRemove(d:GetControler(),POS_FACEDOWN,REASON_RULE) end
end
-- 效果处理：验证两只怪兽是否仍在战斗中，调整变量使a代表己方怪兽、d代表对方怪兽，然后进行猜拳，将输的玩家的战斗怪兽里侧表示除外
function c58297729.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	if a:IsControler(1-tp) then a,d=d,a end
	-- 进行猜拳，平局时重新猜，直到分出胜负，并返回胜利玩家的代号
	local res=Duel.RockPaperScissors()
	if res==tp then
		-- 将对方（猜拳输掉的玩家）的战斗怪兽里侧表示除外
		Duel.Remove(d,POS_FACEDOWN,REASON_RULE)
	else
		-- 将自己（猜拳输掉的玩家）的战斗怪兽里侧表示除外
		Duel.Remove(a,POS_FACEDOWN,REASON_RULE)
	end
end

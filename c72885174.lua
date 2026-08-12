--フォーチュン・スリップ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效，1只攻击对象怪兽直到下次的准备阶段时从游戏中除外。
function c72885174.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效，1只攻击对象怪兽直到下次的准备阶段时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c72885174.condition)
	e1:SetTarget(c72885174.target)
	e1:SetOperation(c72885174.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c72885174.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且存在被攻击的怪兽
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()
end
-- 定义效果的目标选择函数，检查攻击怪兽和攻击对象是否可以成为效果对象
function c72885174.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return a:IsOnField() and a:IsCanBeEffectTarget(e)
		and d:IsOnField() and d:IsAbleToRemove() and d:IsCanBeEffectTarget(e) end
	local g=Group.FromCards(a,d)
	-- 将攻击怪兽和攻击对象怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示此效果包含将1只攻击对象怪兽除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,d,1,0,0)
end
-- 定义效果处理函数，无效攻击并暂时除外攻击对象怪兽
function c72885174.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽
	local tc=Duel.GetAttackTarget()
	-- 确认攻击怪兽和攻击对象怪兽仍对应此效果，并将攻击对象怪兽以效果原因暂时除外
	if a:IsRelateToEffect(e) and a:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 直到下次的准备阶段时
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c72885174.retop)
		-- 注册全局延迟效果，用于在下次准备阶段将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义将暂时除外的怪兽返回场上的效果处理函数
function c72885174.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end

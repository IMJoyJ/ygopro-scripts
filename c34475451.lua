--工作列車シグナル・レッド
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。这张卡不会被那次战斗破坏。
function c34475451.initial_effect(c)
	-- 创建一个字段诱发即时效果，满足条件时可以从手卡特殊召唤此卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34475451,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34475451.condition)
	e1:SetTarget(c34475451.target)
	e1:SetOperation(c34475451.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：对方怪兽攻击宣言时
function c34475451.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽的控制者不是效果发动者
	return Duel.GetAttacker():GetControler()~=tp
end
-- 效果目标：检查是否有足够的怪兽区域并确认此卡可以特殊召唤
function c34475451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将此卡特殊召唤到场上，并设置其不会被那次战斗破坏
function c34475451.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡存在于场上且成功特殊召唤，然后进行后续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 使此卡在战斗中不会被破坏
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			c:RegisterEffect(e1)
			-- 进行攻击伤害计算，使攻击怪兽对特殊召唤的此卡造成伤害
			Duel.CalculateDamage(a,c)
		end
	end
end

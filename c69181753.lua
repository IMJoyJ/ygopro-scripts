--EMクリボーダー
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。那次战斗让自己受到战斗伤害的场合，作为代替让自己基本分回复那个数值。
function c69181753.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。那次战斗让自己受到战斗伤害的场合，作为代替让自己基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69181753,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c69181753.hspcon)
	e1:SetTarget(c69181753.hsptg)
	e1:SetOperation(c69181753.hspop)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：对方怪兽直接攻击宣言时
function c69181753.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽是否由对方控制，且攻击对象为空（即直接攻击）
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置操作信息
function c69181753.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，确认己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤自身，转移攻击对象并进行伤害计算，同时适用伤害变回复的效果
function c69181753.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将此卡在己方场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前进行攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 那次战斗让自己受到战斗伤害的场合，作为代替让自己基本分回复那个数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_REVERSE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c69181753.rev)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			c:RegisterEffect(e1)
			-- 令攻击怪兽与此卡进行战斗伤害计算
			Duel.CalculateDamage(a,c)
		end
	end
end
-- 伤害变回复效果的过滤函数，限定为自身参与的战斗伤害
function c69181753.rev(e,re,r,rp,rc)
	-- 判断伤害原因是否为战斗，且自身为当前的攻击对象
	return bit.band(r,REASON_BATTLE)~=0 and e:GetHandler()==Duel.GetAttackTarget()
end

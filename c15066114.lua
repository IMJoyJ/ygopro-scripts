--セグメンタル・ドラゴン
-- 效果：
-- ①：这张卡可以不用解放作通常召唤。
-- ②：这张卡的①的方法通常召唤的这张卡的原本的攻击力·守备力变成一半。
-- ③：1回合1次，这张卡是已通常召唤的场合才能发动。表侧表示的这张卡破坏，持有那个攻击力以下的攻击力的主要怪兽区域的怪兽全部破坏。这个效果在对方回合也能发动。
function c15066114.initial_effect(c)
	-- 效果原文：①：这张卡可以不用解放作通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15066114,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c15066114.ntcon)
	e1:SetOperation(c15066114.ntop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 效果原文：③：1回合1次，这张卡是已通常召唤的场合才能发动。表侧表示的这张卡破坏，持有那个攻击力以下的攻击力的主要怪兽区域的怪兽全部破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15066114,1))  --"怪兽破坏"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c15066114.descon)
	e3:SetTarget(c15066114.destg)
	e3:SetOperation(c15066114.desop)
	c:RegisterEffect(e3)
end
-- 规则层面：检查是否满足不需解放的通常召唤条件
function c15066114.ntcon(e,c,minc)
	if c==nil then return true end
	-- 规则层面：召唤时不需要解放，等级不低于5，且场上存在可用怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 规则层面：设置该卡原本攻击力和守备力为一半（攻击力1300，守备力1200）
function c15066114.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 规则层面：设置自身原本攻击力为1300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1300)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
end
-- 规则层面：判断该卡是否为通常召唤
function c15066114.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 规则层面：过滤满足条件的怪兽（表侧表示、攻击力不超过指定值、在主要怪兽区域）
function c15066114.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:GetSequence()<5
end
-- 规则层面：准备发动破坏效果，检索满足条件的怪兽组并设置操作信息
function c15066114.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面：判断是否满足发动条件（场上存在攻击力不超过自身攻击力的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c15066114.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack()) end
	-- 规则层面：获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c15066114.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	g:AddCard(c)
	-- 规则层面：设置连锁操作信息，指定将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面：执行破坏效果，先破坏自身，再破坏符合条件的怪兽
function c15066114.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetAttack()
		-- 规则层面：确认自身被破坏成功后，继续执行后续破坏操作
		if Duel.Destroy(c,REASON_EFFECT)~=0 then
			-- 规则层面：获取满足条件的怪兽组（攻击力不超过自身攻击力）
			local g=Duel.GetMatchingGroup(c15066114.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
			-- 规则层面：将符合条件的怪兽全部破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

--森の聖霊 エーコ
-- 效果：
-- 对方的卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，给与对方基本分和受到的伤害相同的伤害。并且，再让这个回合双方受到的效果伤害变成0。
function c4192696.initial_effect(c)
	-- 创建一个诱发选发效果，当对方的卡的效果让自己受到伤害时才能发动，效果描述为特殊召唤，分类为特殊召唤和伤害，效果类型为场地区域诱发选发效果，生效区域为手卡，触发事件为造成伤害，条件为spcon，目标为sptg，效果处理为spop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4192696,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c4192696.spcon)
	e1:SetTarget(c4192696.sptg)
	e1:SetOperation(c4192696.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：伤害的受害者是自己，伤害的来源是对方，伤害原因包含效果伤害
function c4192696.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and 1-tp==rp and bit.band(r,REASON_EFFECT)~=0
end
-- 效果处理目标：判断是否满足特殊召唤条件，包括场上是否有空位以及自身是否可以特殊召唤
function c4192696.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤作为处理目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：将对方基本分造成与受到伤害相同数值的伤害作为处理目标
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 效果处理函数：判断自身是否有效，若有效则特殊召唤自身，然后对对方造成与受到伤害相同数值的伤害，并设置双方本回合效果伤害为0
function c4192696.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否与效果相关且特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 对对方造成与受到伤害相同数值的伤害
		Duel.Damage(1-tp,ev,REASON_EFFECT)
		-- 创建一个影响双方玩家的伤害变更效果，使效果伤害变为0，并注册该效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetValue(c4192696.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将伤害变更效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果伤害免伤效果注册给玩家
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害值变更函数：若伤害原因为效果伤害则返回0，否则返回原伤害值
function c4192696.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end

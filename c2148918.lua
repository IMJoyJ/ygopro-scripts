--機甲忍法ラスト・ミスト
-- 效果：
-- 自己场上有名字带有「忍者」的怪兽存在，对方场上有怪兽特殊召唤时，那些特殊召唤的怪兽的攻击力变成一半。
function c2148918.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上有名字带有「忍者」的怪兽存在，对方场上有怪兽特殊召唤时，那些特殊召唤的怪兽的攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2148918,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c2148918.spcon)
	e2:SetTarget(c2148918.sptg)
	e2:SetOperation(c2148918.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且属于「忍者」字段（0x2b），用于确认自己场上是否存在名字带有「忍者」的怪兽。
function c2148918.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 过滤函数：判断特殊召唤成功的怪兽是否为对方场上的表侧表示怪兽，并且在效果处理时仍与效果e相关（即没有被重置或离场）。
function c2148918.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and (not e or c:IsRelateToEffect(e))
end
-- 效果发动条件：本次特殊召唤成功的怪兽中存在符合条件（对方场上的表侧表示怪兽）的卡，并且自己场上有表侧表示的名字带有「忍者」的怪兽存在。
function c2148918.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断：eg中存在至少1只满足对方表侧怪兽条件的卡，且自己场上有表侧表示的「忍者」怪兽，两者同时成立时返回真。
	return eg:IsExists(c2148918.tgfilter,1,nil,nil,1-tp) and Duel.IsExistingMatchingCard(c2148918.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果的发动目标处理：在发动时无需额外选择，直接返回true；并将本次特殊召唤成功的怪兽组eg设为效果处理时关联的对象。
function c2148918.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将eg（本次特殊召唤成功的所有怪兽）设置为当前连锁效果的处理对象，用于后续效果处理时确认哪些怪兽受此效果影响。
	Duel.SetTargetCard(eg)
end
-- 效果处理：从特殊召唤成功的怪兽中筛选出满足条件的对方表侧怪兽，对其中每只怪兽赋予一个临时效果，将其攻击力变为原攻击力的一半（向上取整），该效果在怪兽离场或被重置时消失。
function c2148918.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c2148918.tgfilter,nil,e,1-tp)
	local tc=g:GetFirst()
	while tc do
		-- 那些特殊召唤的怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

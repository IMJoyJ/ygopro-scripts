--薔薇の妖精
-- 效果：
-- 这张卡被魔法·陷阱·效果怪兽的效果从自己卡组加入手卡的场合，这张卡可以在自己场上特殊召唤。
function c44125452.initial_effect(c)
	-- 这张卡被魔法·陷阱·效果怪兽的效果从自己卡组加入手卡的场合，这张卡可以在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44125452,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c44125452.condition)
	e1:SetTarget(c44125452.target)
	e1:SetOperation(c44125452.operation)
	c:RegisterEffect(e1)
end
-- 诱发条件判定：加入手卡时必须是由于卡片效果，且该卡的前一位置是自己卡组、前一控制者是自己，即满足“被效果从自己卡组加入手卡”。
function c44125452.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsPreviousControler(tp)
end
-- 定义目标判定函数：在发动检查（chk==0）时，验证该卡仍与效果关联、己方怪兽区有空位且该卡可以被特殊召唤，验证通过则效果可以发动。
function c44125452.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查：该卡仍与本次效果关联，且己方场上有空余的怪兽区域可用。
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将本次效果处理登记为“把该卡特殊召唤”（1只），用于连锁判定等目的的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数：取得效果持有者，若该卡仍与效果关联，则执行特殊召唤。
function c44125452.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

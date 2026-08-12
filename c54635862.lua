--ジェントルーパー
-- 效果：
-- 对方怪兽的攻击宣言时，这张卡可以从手卡特殊召唤。只要这张卡在场上表侧表示存在，对方不能向其他怪兽攻击。
function c54635862.initial_effect(c)
	-- 对方怪兽的攻击宣言时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54635862,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c54635862.condition)
	e1:SetTarget(c54635862.target)
	e1:SetOperation(c54635862.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，对方不能向其他怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c54635862.atlimit)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的发动条件：对方怪兽进行攻击宣言时
function c54635862.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前进行攻击宣言的怪兽控制者是否为对方玩家
	return Duel.GetAttacker():GetControler()~=tp
end
-- 特殊召唤效果的发动准备：检查我方怪兽区是否有空位以及自身是否能特殊召唤
function c54635862.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段（chk==0）检查我方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤
function c54635862.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到我方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击限制的过滤条件：攻击目标不能是自身（即只能选择自身作为攻击目标）
function c54635862.atlimit(e,c)
	return c~=e:GetHandler()
end

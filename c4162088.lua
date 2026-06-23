--サイバー・レーザー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。这张卡只能通过「光子发生装置」的效果特殊召唤。可以把持有这张卡攻击力以上的攻击力·守备力的1只怪兽破坏。这个效果1回合只能使用1次。
function c4162088.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡只能通过「光子发生装置」的效果特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 可以把持有这张卡攻击力以上的攻击力·守备力的1只怪兽破坏。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4162088,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c4162088.target)
	e2:SetOperation(c4162088.operation)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否满足攻击力或守备力条件
function c4162088.filter(c,atk)
	return c:IsFaceup() and (c:IsAttackAbove(atk) or c:IsDefenseAbove(atk))
end
-- 设置效果目标为满足条件的怪兽
function c4162088.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4162088.filter(chkc,e:GetHandler():GetAttack()) end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c4162088.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c4162088.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 设置效果操作信息，确定破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标怪兽破坏
function c4162088.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c4162088.filter(tc,c:GetAttack()) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

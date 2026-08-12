--アマゾネスの賢者
-- 效果：
-- 这张卡攻击的场合，那次伤害步骤结束时选择对方场上存在的1张魔法·陷阱卡破坏。
function c53162898.initial_effect(c)
	-- 创建一个诱发必发效果，用于在伤害步骤结束时破坏对方场上的魔法·陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53162898,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c53162898.condition)
	e1:SetTarget(c53162898.target)
	e1:SetOperation(c53162898.operation)
	c:RegisterEffect(e1)
end
-- 判断发动效果的卡是否为本次战斗的攻击怪兽且未离场
function c53162898.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前处理的效果是否由本次战斗的攻击怪兽触发
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 定义过滤器函数，用于筛选魔法或陷阱类型的卡片
function c53162898.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择逻辑，允许选择对方场上的魔法·陷阱卡
function c53162898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c53162898.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上满足条件的1张魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c53162898.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息为破坏效果，并指定目标卡片数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果的处理流程，将选中的目标卡片破坏
function c53162898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

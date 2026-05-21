--BF－鉄鎖のフェーン
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，对方场上攻击表示存在的1只怪兽变成守备表示。
function c9109991.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，对方场上攻击表示存在的1只怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9109991,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c9109991.condition)
	e2:SetTarget(c9109991.target)
	e2:SetOperation(c9109991.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数：给与对方玩家战斗伤害且为直接攻击
function c9109991.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方（ep~=tp）且攻击对象为空（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义过滤函数：筛选处于攻击表示且可以改变表示形式的怪兽
function c9109991.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 定义效果的目标选择函数（由于是必发效果，chk==0时直接返回true）
function c9109991.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c9109991.filter(chkc) end
	if chk==0 then return true end
	-- 在客户端提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择对方场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9109991.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：包含改变表示形式分类，操作对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：将作为对象的怪兽改变为守备表示
function c9109991.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsAttackPos() then
		-- 将目标怪兽的表示形式改变为守备表示（表侧守备表示或里侧守备表示）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
	end
end

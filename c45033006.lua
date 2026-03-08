--A・O・J エネミー・キャッチャー
-- 效果：
-- 这张卡召唤成功时，直到这个回合的结束阶段时可以得到对方场上里侧守备表示存在的1只怪兽的控制权。
function c45033006.initial_effect(c)
	-- 这张卡召唤成功时，直到这个回合的结束阶段时可以得到对方场上里侧守备表示存在的1只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45033006,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45033006.target)
	e1:SetOperation(c45033006.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足里侧表示、守备表示且控制权可改变的怪兽
function c45033006.filter(c)
	return c:IsFacedown() and c:IsDefensePos() and c:IsControlerCanBeChanged()
end
-- 选择对方场上满足条件的1只怪兽作为效果对象
function c45033006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45033006.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c45033006.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽
	local g=Duel.SelectTarget(tp,c45033006.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 将目标怪兽的控制权转移给发动玩家直到结束阶段
function c45033006.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsDefensePos() then
		-- 将目标怪兽的控制权转移给发动玩家直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

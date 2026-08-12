--墓守の暗殺者
-- 效果：
-- 「王家长眠之谷」在场上表侧表示存在时效果才能发动。这张卡攻击宣言时，可以变更对方场上存在的一只表侧表示怪兽的表示形式。
function c25262697.initial_effect(c)
	-- 创建效果，描述为“改变表示形式”，分类为改变表示形式，类型为单体诱发效果，取对象，攻击宣言时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25262697,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c25262697.poscon)
	e1:SetTarget(c25262697.postg)
	e1:SetOperation(c25262697.posop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：场地卡“王家长眠之谷”在场上表侧表示存在
function c25262697.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场地卡是否为“王家长眠之谷”
	return Duel.IsEnvironment(47355498)
end
-- 筛选条件：目标怪兽必须表侧表示且可以改变表示形式
function c25262697.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 设置效果目标：选择对方场上一只表侧表示且可改变表示形式的怪兽
function c25262697.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c25262697.filter(chkc) end
	-- 判断是否满足选择目标的条件：对方场上是否存在一只表侧表示且可改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(c25262697.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择一只对方场上表侧表示且可改变表示形式的怪兽作为目标
	local g=Duel.SelectTarget(tp,c25262697.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：确定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将目标怪兽变为表侧守备表示
function c25262697.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end

--竜宮之姫
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡召唤·反转时，可以选择对方场上的1只表侧表示的怪兽改变表示形式。
function c39751093.initial_effect(c)
	-- 为卡片添加在召唤或反转成功后结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无法被无效且不可复制的特殊召唤条件
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，可以选择对方场上的1只表侧表示的怪兽改变表示形式
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(39751093,1))  --"改变表示形式"
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c39751093.target)
	e4:SetOperation(c39751093.operation)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 筛选条件：目标怪兽必须为表侧表示且可以改变表示形式
function c39751093.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 处理效果目标选择：选择对方场上1只表侧表示的怪兽作为目标
function c39751093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c39751093.filter(chkc) end
	-- 判断是否满足发动条件：对方场上是否存在1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c39751093.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只表侧表示的怪兽作为目标
	local g=Duel.SelectTarget(tp,c39751093.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将目标怪兽改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果执行：将目标怪兽变为守备表示
function c39751093.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end

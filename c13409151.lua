--砂バク
-- 效果：
-- ①：这张卡反转的场合，以「沙貘」以外的场上1只表侧表示怪兽为对象发动。那只怪兽变成里侧守备表示。
function c13409151.initial_effect(c)
	-- ①：这张卡反转的场合，以「沙貘」以外的场上1只表侧表示怪兽为对象发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13409151,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c13409151.postg)
	e1:SetOperation(c13409151.posop)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选满足条件的怪兽（表侧表示、非沙貘、可转为里侧表示）
function c13409151.filter(c)
	return c:IsFaceup() and not c:IsCode(13409151) and c:IsCanTurnSet()
end
-- 设置效果的目标选择函数，用于选择符合条件的怪兽作为目标
function c13409151.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13409151.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c13409151.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要改变目标怪兽的表示形式为里侧守备
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 设置效果的处理函数，用于执行怪兽变为里侧守备表示的操作
function c13409151.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

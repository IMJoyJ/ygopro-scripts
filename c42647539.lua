--ガーゴイルの道化師
-- 效果：
-- 这张卡片召唤·反转召唤·特殊召唤时可以使对方1只表侧表示的怪兽的表示形式改变。
function c42647539.initial_effect(c)
	-- 这张卡片召唤·反转召唤·特殊召唤时可以使对方1只表侧表示的怪兽的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42647539,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42647539.postg)
	e1:SetOperation(c42647539.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 筛选满足表侧表示且可以改变表示形式的怪兽
function c42647539.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 选择对方场上1只表侧表示的怪兽作为效果对象
function c42647539.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c42647539.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c42647539.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 将选中的怪兽变为守备表示
function c42647539.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end

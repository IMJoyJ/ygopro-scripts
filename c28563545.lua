--竜殺者
-- 效果：
-- 这张卡在场上召唤·反转召唤时，破坏表侧表示的1只龙族怪兽。
function c28563545.initial_effect(c)
	-- 这张卡在场上召唤·反转召唤时，破坏表侧表示的1只龙族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28563545,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28563545.target)
	e1:SetOperation(c28563545.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查目标怪兽是否为表侧表示的龙族怪兽
function c28563545.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 选择1只表侧表示的龙族怪兽作为破坏对象
function c28563545.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28563545.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选取满足条件的1只龙族怪兽作为目标
	local g=Duel.SelectTarget(tp,c28563545.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将选中的龙族怪兽破坏
function c28563545.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c28563545.filter(tc) then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

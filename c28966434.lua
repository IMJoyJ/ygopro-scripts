--ソリテア・マジカル
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「命运女郎」的怪兽和场上表侧表示存在的1只怪兽发动。选择的名字带有「命运女郎」的怪兽的等级下降3星，选择的另1只怪兽破坏。这个效果1回合只能使用1次。
function c28966434.initial_effect(c)
	-- 创建一个起动效果，可以破坏对方怪兽，且只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28966434,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c28966434.destg)
	e1:SetOperation(c28966434.desop)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示存在的名字带有「命运女郎」且等级大于等于4的怪兽
function c28966434.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x31) and c:IsLevelAbove(4)
end
-- 筛选场上表侧表示存在的任意怪兽
function c28966434.filter2(c)
	return c:IsFaceup()
end
-- 判断是否满足选择目标的条件
function c28966434.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断场上是否存在满足filter1条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c28966434.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 判断场上是否存在满足filter2条件的怪兽
		and Duel.IsExistingTarget(c28966434.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择等级下降的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(28966434,1))  --"请选择等级下降的怪兽"
	-- 选择满足filter1条件的怪兽作为目标
	local g1=Duel.SelectTarget(tp,c28966434.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足filter2条件的怪兽作为目标
	local g2=Duel.SelectTarget(tp,c28966434.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst())
	e:SetLabelObject(g1:GetFirst())
	-- 设置连锁操作信息，表示将要破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 处理效果的发动，先获取目标怪兽，再对目标怪兽进行等级下降和破坏操作
function c28966434.desop(e,tp,eg,ep,ev,re,r,rp)
	local c1=e:GetLabelObject()
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==c1 then tc=g:GetNext() end
	if c1:IsLevelBelow(3) or c1:IsFacedown() or not c1:IsRelateToEffect(e) then return end
	-- 创建一个改变等级的效果，使目标怪兽等级下降3星
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c1:RegisterEffect(e1)
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end

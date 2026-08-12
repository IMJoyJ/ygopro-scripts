--ブラック・リターン
-- 效果：
-- 名字带有「黑羽」的怪兽1只特殊召唤成功时，选择对方场上表侧表示存在的1只怪兽发动。自己基本分回复选择的对方怪兽的攻击力的数值，那只怪兽回到持有者手卡。
function c72278479.initial_effect(c)
	-- 名字带有「黑羽」的怪兽1只特殊召唤成功时，选择对方场上表侧表示存在的1只怪兽发动。自己基本分回复选择的对方怪兽的攻击力的数值，那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c72278479.condition)
	e1:SetTarget(c72278479.target)
	e1:SetOperation(c72278479.activate)
	c:RegisterEffect(e1)
end
-- 判定是否为1只名字带有「黑羽」的怪兽特殊召唤成功的时点
function c72278479.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsSetCard(0x33)
end
-- 过滤对方场上表侧表示、可以回到手卡且攻击力大于0的怪兽
function c72278479.filter(c)
	return c:IsFaceup() and c:IsAbleToHand() and c:GetAttack()>0
end
-- 效果发动时的对象选择与操作信息注册
function c72278479.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c72278479.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件的表侧表示怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c72278479.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72278479.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置当前连锁的操作信息为：自己回复生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 效果处理函数，执行回复生命值并使目标怪兽回到手卡的操作
function c72278479.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 自己回复该怪兽攻击力数值的生命值
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
		-- 将目标怪兽送回持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

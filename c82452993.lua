--孤高の格闘家
-- 效果：
-- 自己场上只有「格斗鼠 吱助」「武僧战士」「武僧大师」内的其中1只存在的场合才能发动。这只怪兽不会被战斗破坏，不会受到对方怪兽的效果影响。
function c82452993.initial_effect(c)
	-- 在卡片中注册记载有「格斗鼠 吱助」「武僧战士」「武僧大师」的卡片密码
	aux.AddCodeList(c,8508055,3810071,49814180)
	-- 自己场上只有「格斗鼠 吱助」「武僧战士」「武僧大师」内的其中1只存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c82452993.target)
	e1:SetOperation(c82452993.operation)
	c:RegisterEffect(e1)
	-- 这只怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c82452993.efilter)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且卡名为「格斗鼠 吱助」、「武僧战士」或「武僧大师」的怪兽
function c82452993.filter(c)
	return c:IsFaceup() and c:IsCode(8508055,3810071,49814180)
end
-- 发动时的对象选择与合法性检测：确认自己场上仅存在1只怪兽且为符合条件的怪兽，并将其作为效果对象
function c82452993.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上怪兽区的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if chk==0 then return g:GetCount()==1 and c82452993.filter(g:GetFirst()) end
	-- 将符合条件的怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
end
-- 效果处理：若此卡与目标怪兽均在场，则将目标怪兽作为此卡的永续对象
function c82452993.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 免疫效果过滤器：判定来源效果是否为对方玩家的怪兽效果
function c82452993.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

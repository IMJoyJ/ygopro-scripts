--進化の繭
-- 效果：
-- 这张卡可以从手卡当作装备卡使用给场上表侧表示存在的「飞蛾宝宝」装备。用这个效果把这张卡装备的「飞蛾宝宝」的攻击力·守备力按「进化之茧」的数值适用。
function c40240595.initial_effect(c)
	-- 效果原文：这张卡可以从手卡当作装备卡使用给场上表侧表示存在的「飞蛾宝宝」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40240595,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c40240595.eqtg)
	e1:SetOperation(c40240595.eqop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「飞蛾宝宝」怪兽（表侧表示且卡号为58192742）
function c40240595.filter(c)
	return c:IsFaceup() and c:IsCode(58192742)
end
-- 效果原文：这张卡可以从手卡当作装备卡使用给场上表侧表示存在的「飞蛾宝宝」装备。
function c40240595.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40240595.filter(chkc) end
	-- 判断玩家场上是否有足够的魔陷区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家场上是否存在满足条件的「飞蛾宝宝」怪兽
		and Duel.IsExistingTarget(c40240595.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的「飞蛾宝宝」怪兽作为装备对象
	Duel.SelectTarget(tp,c40240595.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果原文：用这个效果把这张卡装备的「飞蛾宝宝」的攻击力·守备力按「进化之茧」的数值适用。
function c40240595.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足（包括魔陷区空位、对象控制权、对象表示形式等）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 效果原文：用这个效果把这张卡装备的「飞蛾宝宝」的攻击力·守备力按「进化之茧」的数值适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c40240595.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 设置装备卡在结束阶段时触发的计数器效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c40240595.checkcon)
	e2:SetOperation(c40240595.checkop)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 设置装备卡使目标怪兽攻击力变为0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetValue(0)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- 设置装备卡使目标怪兽守备力变为2000
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
	e4:SetValue(2000)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
	c:SetTurnCounter(0)
end
-- 判断是否为当前回合玩家
function c40240595.checkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段时增加计数器数值
function c40240595.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
end
-- 限制只能装备给特定怪兽
function c40240595.eqlimit(e,c)
	return c==e:GetLabelObject()
end

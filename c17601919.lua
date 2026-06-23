--ゴースト姫－パンプリンセス－
-- 效果：
-- 这张卡在怪兽卡区域上被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱卡区域表侧表示放置。这个效果当作永续魔法卡使用的场合，每次双方的准备阶段给这张卡放置1个南瓜指示物。对方场上的全部怪兽的攻击力·守备力下降当作永续魔法卡使用的这张卡放置的南瓜指示物数量×100的数值。
function c17601919.initial_effect(c)
	c:EnableCounterPermit(0x2f,LOCATION_SZONE)
	-- 这张卡在怪兽卡区域上被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱卡区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c17601919.repcon)
	e1:SetOperation(c17601919.repop)
	c:RegisterEffect(e1)
end
-- 满足破坏条件时触发效果
function c17601919.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将自身转换为永续魔法卡类型并注册指示物效果和攻击力守备力下降效果
function c17601919.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将自身转换为永续魔法卡类型
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	-- 每次双方的准备阶段给这张卡放置1个南瓜指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17601919,1))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetTarget(c17601919.addct)
	e2:SetOperation(c17601919.addc)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 对方场上的全部怪兽的攻击力·守备力下降当作永续魔法卡使用的这张卡放置的南瓜指示物数量×100的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c17601919.adval)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 设置连锁操作信息，表示将要放置指示物
function c17601919.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置放置指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x2f)
end
-- 为自身添加一个南瓜指示物
function c17601919.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x2f,1)
	end
end
-- 计算并返回南瓜指示物数量乘以-100的数值作为攻击力守备力的减少值
function c17601919.adval(e,c)
	return e:GetHandler():GetCounter(0x2f)*-100
end

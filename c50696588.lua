--GUYダンス
--not fully implemented (require other cards to be updated)
-- 效果：
-- 这个卡名的效果在决斗中只能适用1次。
-- ①：指定没有使用的对方的主要怪兽区域1处才能发动。只要指定的区域是可以使用，对方要在主要怪兽区域把怪兽通常召唤·特殊召唤的场合，不是那个区域不能使用。这个效果直到指定的区域有怪兽被放置为止适用。
function c50696588.initial_effect(c)
	-- ①：指定没有使用的对方的主要怪兽区域1处才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50696588.cost)
	e1:SetTarget(c50696588.target)
	e1:SetOperation(c50696588.activate)
	c:RegisterEffect(e1)
end
-- 这个卡名的效果在决斗中只能适用1次。
function c50696588.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否已使用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,50696588)==0 end
end
-- 选择对方一个可用的怪兽区域
function c50696588.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确保对方场上存在可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 让玩家选择一个对方的怪兽区域
	local flag=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	e:SetLabel(flag)
	-- 提示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,flag)
end
-- 发动效果后，检查所选区域是否仍可用且未使用过此效果
function c50696588.activate(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabel()
	local seq=math.log(bit.rshift(flag,16),2)
	-- 检查所选区域是否仍然可用
	if not Duel.CheckLocation(1-tp,LOCATION_MZONE,seq)
		-- 检查是否已使用过此效果
		or Duel.GetFlagEffect(tp,50696588)~=0 then return end
	-- 注册标识效果，防止再次使用此卡效果
	Duel.RegisterFlagEffect(tp,50696588,0,0,0)
	-- 只要指定的区域是可以使用，对方要在主要怪兽区域把怪兽通常召唤·特殊召唤的场合，不是那个区域不能使用。这个效果直到指定的区域有怪兽被放置为止适用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetTargetRange(0,1)
	e1:SetValue(flag | 0x600060)
	e1:SetCountLimit(1)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end

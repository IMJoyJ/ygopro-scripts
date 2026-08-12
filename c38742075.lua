--辺境の大賢者
-- 效果：
-- 只要这张卡在自己的场上存在，以自己场上的表侧表示存在的战士族怪兽为对象的魔法卡的效果无效并破坏。
function c38742075.initial_effect(c)
	-- 以自己场上的表侧表示存在的战士族怪兽为对象的魔法卡的效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c38742075.distg)
	c:RegisterEffect(e1)
	-- 连锁处理开始时触发
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c38742075.disop)
	c:RegisterEffect(e2)
	-- 以自己场上的表侧表示存在的战士族怪兽为对象的魔法卡在发动时自动破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c38742075.distg)
	c:RegisterEffect(e3)
end
-- 检查目标怪兽是否为表侧表示、战士族、属于自己、在主要怪兽区
function c38742075.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 判断目标魔法卡是否以战士族怪兽为对象且对象存在
function c38742075.distg(e,c)
	return c:GetCardTargetCount()>0 and c:IsType(TYPE_SPELL)
		and c:GetCardTarget():IsExists(c38742075.cfilter,1,nil,e:GetHandlerPlayer())
end
-- 处理连锁效果，若为魔法卡且有对象，则使效果无效并破坏发动的魔法卡
function c38742075.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsExists(c38742075.cfilter,1,nil,tp) then return end
	-- 使当前连锁效果无效并检查发动卡是否有效
	if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的魔法卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

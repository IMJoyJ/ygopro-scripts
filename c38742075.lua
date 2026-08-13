--辺境の大賢者
-- 效果：
-- 只要这张卡在自己的场上存在，以自己场上的表侧表示存在的战士族怪兽为对象的魔法卡的效果无效并破坏。
function c38742075.initial_effect(c)
	-- 只要这张卡在自己的场上存在，以自己场上的表侧表示存在的战士族怪兽为对象的魔法卡的效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c38742075.distg)
	c:RegisterEffect(e1)
	-- 以自己场上的表侧表示存在的战士族怪兽为对象的魔法卡的效果无效并破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c38742075.disop)
	c:RegisterEffect(e2)
	-- 并破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c38742075.distg)
	c:RegisterEffect(e3)
end
-- 筛选满足条件的对象卡：该卡必须是表侧表示、战士族、控制者为tp且位于主要怪兽区，用于判断魔法卡所取的对象是否是自己场上的表侧战士族怪兽。
function c38742075.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 判定一张魔法卡是否属于“以自己场上的表侧表示存在的战士族怪兽为对象”的魔法卡：该魔法卡存在取对象，且其取对象中存在符合cfilter条件的卡片。
function c38742075.distg(e,c)
	return c:GetCardTargetCount()>0 and c:IsType(TYPE_SPELL)
		and c:GetCardTarget():IsExists(c38742075.cfilter,1,nil,e:GetHandlerPlayer())
end
-- 在魔法卡发动进入连锁处理时，若该魔法卡是取对象效果且对象包含自己场上的表侧战士族怪兽，则将其效果无效并破坏。
function c38742075.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前正在处理的连锁效果所取的对象卡组，用于检查对象中是否存在符合条件的战士族怪兽。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsExists(c38742075.cfilter,1,nil,tp) then return end
	-- 尝试将当前连锁中的魔法卡效果无效；如果无效成功且该魔法卡仍与效果相关联（未被除外或离开相关区域），则继续执行后续的破坏处理。
	if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该魔法卡本身破坏，实现效果原文中的“并破坏”。
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

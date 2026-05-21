--タイラント・ドラゴン
--not fully implemented
-- 效果：
-- 只在对方场上有怪兽存在的场合才在战斗阶段中只再1次可以攻击。此外，以这张卡为对象的陷阱卡无效并破坏。其他卡的效果把这张卡从墓地特殊召唤的场合，必须把自己场上1只龙族怪兽作为祭品。
function c94568601.initial_effect(c)
	-- 以这张卡为对象的陷阱卡无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c94568601.distg)
	c:RegisterEffect(e1)
	-- 以这张卡为对象的陷阱卡无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c94568601.disop)
	c:RegisterEffect(e2)
	-- 以这张卡为对象的陷阱卡无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c94568601.distg)
	c:RegisterEffect(e3)
	-- 只在对方场上有怪兽存在的场合才在战斗阶段中只再1次可以攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	e4:SetCondition(c94568601.atkcon)
	c:RegisterEffect(e4)
	-- 其他卡的效果把这张卡从墓地特殊召唤的场合，必须把自己场上1只龙族怪兽作为祭品。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCost(c94568601.spcost)
	e5:SetOperation(c94568601.spcop)
	c:RegisterEffect(e5)
end
-- 过滤出以自身为对象的陷阱卡
function c94568601.distg(e,c)
	if not c:IsType(TYPE_TRAP) or c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsContains(e:GetHandler())
end
-- 在连锁处理时，无效并破坏以自身为对象的陷阱卡的效果
function c94568601.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsContains(e:GetHandler()) then
		-- 若成功无效该连锁的效果且该卡仍与效果关联
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 因效果原因破坏该卡
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 判断是否满足追加攻击的条件
function c94568601.atkcon(e)
	-- 判断对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
-- 检查是否能支付特殊召唤的代价（解放1只龙族怪兽）
function c94568601.spcost(e,c,tp)
	-- 检查自己场上是否存在至少1只可以解放的龙族怪兽
	return Duel.CheckReleaseGroupEx(tp,Card.IsRace,1,REASON_ACTION,false,nil,RACE_DRAGON)
end
-- 执行特殊召唤的代价（解放1只龙族怪兽）
function c94568601.spcop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择自己场上1只用于解放的龙族怪兽
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_ACTION,false,nil,RACE_DRAGON)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_ACTION)
end

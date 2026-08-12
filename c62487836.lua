--白の咆哮
-- 效果：
-- ①：自己场上有水属性怪兽存在的场合，以对方墓地1张魔法卡为对象才能发动。那张卡除外，这个回合，对方场上的魔法卡的效果无效化。
function c62487836.initial_effect(c)
	-- ①：自己场上有水属性怪兽存在的场合，以对方墓地1张魔法卡为对象才能发动。那张卡除外，这个回合，对方场上的魔法卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c62487836.condition)
	e1:SetTarget(c62487836.target)
	e1:SetOperation(c62487836.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的水属性怪兽
function c62487836.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 发动条件：自己场上有水属性怪兽存在
function c62487836.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的水属性怪兽
	return Duel.IsExistingMatchingCard(c62487836.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：对方墓地可以被除外的魔法卡
function c62487836.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果发动：选择对方墓地1张魔法卡为对象，并设置除外操作信息
function c62487836.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c62487836.filter(chkc) end
	-- 检查对方墓地是否存在可以被除外的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c62487836.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c62487836.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁操作信息：除外对方墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理：除外目标卡片，并注册使对方场上魔法卡效果无效化的效果
function c62487836.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍符合条件，则将其表侧表示除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_REMOVED) then
		-- 这个回合，对方场上的魔法卡的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetTargetRange(0,LOCATION_SZONE)
		e2:SetTarget(c62487836.distg)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使对方场上魔法卡无效的场上效果
		Duel.RegisterEffect(e2,tp)
		-- 这个回合，对方场上的魔法卡的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_SOLVING)
		e3:SetRange(LOCATION_MZONE)
		e3:SetOperation(c62487836.disop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在连锁处理时使对方场上发动的魔法卡效果无效的辅助效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 过滤条件：适用于无效化效果的魔法卡
function c62487836.distg(e,c)
	return c:IsType(TYPE_SPELL)
end
-- 连锁处理时的无效化操作：若对方在魔陷区发动魔法卡的效果，则将其无效
function c62487836.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理中的连锁的发动位置和发动玩家
	local loc,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_PLAYER)
	if loc==LOCATION_SZONE and p~=tp and re:IsActiveType(TYPE_SPELL) then
		-- 无效该连锁的效果
		Duel.NegateEffect(ev)
	end
end

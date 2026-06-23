--ペンデュラム・エリア
-- 效果：
-- ①：自己场上的怪兽只有灵摆怪兽的场合，以自己的灵摆区域2张卡为对象才能发动。那2张卡破坏，这个回合双方不能作灵摆召唤以外的特殊召唤。
function c2359348.initial_effect(c)
	-- ①：自己场上的怪兽只有灵摆怪兽的场合，以自己的灵摆区域2张卡为对象才能发动。那2张卡破坏，这个回合双方不能作灵摆召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c2359348.condition)
	e1:SetTarget(c2359348.target)
	e1:SetOperation(c2359348.activate)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否为表侧表示的灵摆怪兽
function c2359348.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 判断自己场上是否只有灵摆怪兽
function c2359348.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and g:FilterCount(c2359348.cfilter,nil)==g:GetCount()
end
-- 设置效果的对象为自己的灵摆区域的2张卡
function c2359348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己灵摆区域是否有2张卡可作为对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,2,nil) end
	-- 获取自己灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 将灵摆区域的卡设置为效果对象
	Duel.SetTargetCard(g)
	-- 设置效果操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 处理效果的发动，若对象卡存在且被破坏，则禁止双方进行非灵摆召唤的特殊召唤
function c2359348.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 确认被破坏的卡数量为2且成功破坏
	if sg:GetCount()==2 and Duel.Destroy(sg,REASON_EFFECT)==2 then
		-- 这个回合双方不能作灵摆召唤以外的特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,1)
		e1:SetTarget(c2359348.splimit)
		-- 注册禁止特殊召唤的效果给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制只能进行灵摆召唤的特殊召唤
function c2359348.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)~=SUMMON_TYPE_PENDULUM
end

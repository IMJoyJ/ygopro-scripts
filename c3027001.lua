--偽物のわな
-- 效果：
-- 把自己场上的陷阱卡破坏的魔法·陷阱·效果怪兽的效果对方发动时才能发动，把这张卡作为代替破坏，其他的自己的陷阱卡不破坏。盖放的卡破坏的场合，那些卡全部翻开确认。
function c3027001.initial_effect(c)
	-- 效果发动时的条件判断和目标设置
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3027001.condition)
	e1:SetTarget(c3027001.target)
	e1:SetOperation(c3027001.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上属于自己的陷阱卡
function c3027001.cfilter(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsLocation(LOCATION_SZONE) and c:IsControler(tp)
end
-- 判断是否为对方发动的魔法·陷阱·效果怪兽的效果，且该效果会破坏自己的陷阱卡
function c3027001.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	-- 获取当前连锁中涉及的破坏效果信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tg:GetCount()==tc and tg:IsExists(c3027001.cfilter,1,e:GetHandler(),tp) then
		e:SetLabelObject(re)
		return true
	else return false end
end
-- 过滤场上属于自己的里侧表示的卡
function c3027001.cffilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
-- 设置效果发动时的操作信息，准备将此卡作为破坏对象
function c3027001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
	-- 设置操作信息，表示将此卡作为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 注册代替破坏效果，使此卡在满足条件时代替陷阱卡被破坏
function c3027001.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 注册代替破坏效果，使此卡在满足条件时代替陷阱卡被破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetRange(LOCATION_SZONE)
		e1:SetTarget(c3027001.reptg)
		e1:SetValue(c3027001.repvalue)
		e1:SetOperation(c3027001.repop)
		e1:SetLabelObject(e:GetLabelObject())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 过滤满足条件的陷阱卡，排除已被代替破坏的卡
function c3027001.repfilter(c,tp)
	return c3027001.cfilter(c,tp) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否为触发此效果的连锁，且有满足条件的陷阱卡被破坏
function c3027001.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return re==e:GetLabelObject() and eg:IsExists(c3027001.repfilter,1,c,tp) end
	local sg=eg:Filter(c3027001.repfilter,c,tp)
	local fg=sg:Filter(c3027001.cffilter,nil,tp)
	if fg:GetCount()>0 then
		-- 确认对方看到被破坏的里侧表示卡
		Duel.ConfirmCards(1-tp,fg)
	end
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
-- 返回是否为被代替破坏的卡
function c3027001.repvalue(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end
-- 执行代替破坏效果，将此卡破坏
function c3027001.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从场上破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end

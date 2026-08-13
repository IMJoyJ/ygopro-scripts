--偽物のわな
-- 效果：
-- 把自己场上的陷阱卡破坏的魔法·陷阱·效果怪兽的效果对方发动时才能发动，把这张卡作为代替破坏，其他的自己的陷阱卡不破坏。盖放的卡破坏的场合，那些卡全部翻开确认。
function c3027001.initial_effect(c)
	-- 把自己场上的陷阱卡破坏的魔法·陷阱·效果怪兽的效果对方发动时才能发动，把这张卡作为代替破坏，其他的自己的陷阱卡不破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3027001.condition)
	e1:SetTarget(c3027001.target)
	e1:SetOperation(c3027001.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己的魔法陷阱区的陷阱卡：该卡必须是陷阱卡、位于魔陷区且由 tp 控制。
function c3027001.cfilter(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsLocation(LOCATION_SZONE) and c:IsControler(tp)
end
-- 发动条件：仅当对方发动效果且该效果会破坏自己场上的陷阱卡，且破坏对象与数量已确定并包含自己的陷阱卡时，本卡才能发动；同时保存对方发动的那个效果。
function c3027001.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	-- 获取连锁 ev 中破坏效果的操作信息：ex 表示是否存在破坏分类，tg 为可能被破坏的卡组，tc 为预计破坏数量。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tg:GetCount()==tc and tg:IsExists(c3027001.cfilter,1,e:GetHandler(),tp) then
		e:SetLabelObject(re)
		return true
	else return false end
end
-- 筛选里侧表示且由 tp 控制的卡，用于找出盖放的陷阱卡。
function c3027001.cffilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
-- 发动时的目标处理：chk==0 时确认该效果可以发动，然后登记本卡为破坏对象，为代替破坏做准备。
function c3027001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
	-- 将当前连锁的操作信息设置为破坏自己，数量为 1，使本卡在后续处理中作为将被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时若本卡仍在场上，则为本卡注册一个持续的代替破坏效果：在本卡位于魔陷区期间，当被保存的那个对方效果要破坏自己的陷阱卡时，由本卡代替破坏，并在标准重置时机失效。
function c3027001.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 把这张卡作为代替破坏，其他的自己的陷阱卡不破坏；盖放的卡破坏的场合，那些卡全部翻开确认。
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
-- 筛选需要由本卡代替破坏的自己场上的陷阱卡：满足自己的陷阱卡条件，且未因代替破坏原因被处理过。
function c3027001.repfilter(c,tp)
	return c3027001.cfilter(c,tp) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的判定与处理：当发生破坏事件时，若该破坏效果正是本卡保存的对方效果，且破坏对象中包含自己的陷阱卡，则将这些陷阱卡保存为代破对象，如有里侧卡则给对方确认，然后返回 true。
function c3027001.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return re==e:GetLabelObject() and eg:IsExists(c3027001.repfilter,1,c,tp) end
	local sg=eg:Filter(c3027001.repfilter,c,tp)
	local fg=sg:Filter(c3027001.cffilter,nil,tp)
	if fg:GetCount()>0 then
		-- 让对方玩家确认被代破的里侧表示的陷阱卡。
		Duel.ConfirmCards(1-tp,fg)
	end
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
-- 判断正在被破坏的卡 c 是否在需代破的卡组中，若是则返回 true，表示由本卡代替其破坏。
function c3027001.repvalue(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end
-- 执行代替破坏：先将本卡破坏，再清理保存的代破卡组数据。
function c3027001.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以“效果破坏+代替破坏”的原因将本卡破坏，从而代替其他自己的陷阱卡被破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end

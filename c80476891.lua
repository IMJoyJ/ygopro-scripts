--進化合獣ヒュードラゴン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡以外的二重怪兽召唤成功时才能发动。那只怪兽的攻击力·守备力上升500。
-- ●自己场上的二重怪兽被效果破坏的场合，可以作为代替把自己场上1张卡破坏。
function c80476891.initial_effect(c)
	-- 初始化二重怪兽属性，使其在场上·墓地当作通常怪兽，并可再度召唤
	aux.EnableDualAttribute(c)
	-- ●这张卡以外的二重怪兽召唤成功时才能发动。那只怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80476891,0))  --"攻击力·守备力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	-- 限制效果只能在再度召唤状态下发动
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c80476891.target)
	e1:SetOperation(c80476891.operation)
	c:RegisterEffect(e1)
	-- ●自己场上的二重怪兽被效果破坏的场合，可以作为代替把自己场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	-- 限制代替破坏效果只能在再度召唤状态下适用
	e2:SetCondition(aux.IsDualState)
	e2:SetTarget(c80476891.reptg)
	e2:SetValue(c80476891.repval)
	e2:SetOperation(c80476891.repop)
	c:RegisterEffect(e2)
end
-- 召唤成功效果的Target函数：检查是否有除自身以外的二重怪兽召唤成功，并将其设为效果处理对象
function c80476891.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsType(TYPE_DUAL) and tc~=e:GetHandler() end
	-- 将召唤成功的二重怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
end
-- 召唤成功效果的Operation函数：使目标怪兽的攻击力·守备力上升500
function c80476891.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设为效果处理对象的那只二重怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤需要被代替破坏的卡：自己场上因效果破坏的二重怪兽
function c80476891.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_DUAL) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetFlagEffect(80476891)==0
end
-- 过滤可以作为代替破坏的卡：自己场上可以被效果破坏的卡
function c80476891.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的Target函数：检查是否满足代替破坏的条件，并让玩家选择是否发动以及选择代替破坏的卡
function c80476891.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以代替破坏的卡，以及是否有符合条件的二重怪兽正要被效果破坏
	if chk==0 then return Duel.IsExistingMatchingCard(c80476891.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp)
		and eg:IsExists(c80476891.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c80476891.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 提示玩家选择哪一只二重怪兽需要被代替破坏
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		-- 提示玩家选择自己场上的1张卡作为代替破坏的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择自己场上1张卡作为代替破坏的对象
		local tg=Duel.SelectMatchingCard(tp,c80476891.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
		-- 将选中的代替破坏的卡设为效果处理对象
		Duel.SetTargetCard(tg)
		tg:GetFirst():RegisterFlagEffect(80476891,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
		tg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替值函数：确定被代替破坏的卡是之前选定的那只二重怪兽
function c80476891.repval(e,c)
	return c==e:GetLabelObject()
end
-- 代替破坏效果的Operation函数：执行代替破坏，将选中的代替卡破坏
function c80476891.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了此卡的效果（显示卡片发动动画）
	Duel.Hint(HINT_CARD,0,80476891)
	-- 获取被选为代替破坏对象的卡
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将作为代替的卡因效果代替而破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end

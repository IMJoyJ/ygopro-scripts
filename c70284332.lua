--調律師の陰謀
-- 效果：
-- 对方场上有同调怪兽特殊召唤时才能发动。得到那1只同调怪兽的控制权。这个效果得到控制权的怪兽破坏的场合从游戏中除外。那只怪兽不在场上存在时，这张卡破坏。
function c70284332.initial_effect(c)
	-- 对方场上有同调怪兽特殊召唤时才能发动。得到那1只同调怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c70284332.target)
	e1:SetOperation(c70284332.operation)
	c:RegisterEffect(e1)
	-- 那只怪兽不在场上存在时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c70284332.descon)
	e2:SetOperation(c70284332.desop)
	c:RegisterEffect(e2)
	-- 得到那1只同调怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(c70284332.ctval)
	c:RegisterEffect(e3)
end
-- 过滤出对方场上表侧表示、可以成为效果对象且可以改变控制权的同调怪兽
function c70284332.filter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeEffectTarget(e) and c:IsControlerCanBeChanged()
end
-- 在对方同调怪兽特殊召唤成功时，选择其中1只作为效果对象发动，并设置操作信息为改变控制权
function c70284332.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c70284332.filter(chkc,e,1-tp) end
	if chk==0 then return eg:IsExists(c70284332.filter,1,nil,e,1-tp) end
	-- 给发动效果的玩家发送“请选择要改变控制权的怪兽”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	local g=eg:FilterSelect(tp,c70284332.filter,1,1,nil,e,1-tp)
	-- 将选择的怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为改变1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 将自身与目标怪兽建立持续对象关系，并为目标怪兽注册“因破坏而离场时除外”的重定向效果
function c70284332.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的第1只怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 这个效果得到控制权的怪兽破坏的场合从游戏中除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetCondition(c70284332.dircon)
		e2:SetValue(LOCATION_REMOVED)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 返回当前效果控制权归属于发动该卡效果的玩家
function c70284332.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断目标怪兽离场的原因是否为被破坏
function c70284332.dircon(e)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 判断离场的卡片中是否包含当前卡片所指向的目标怪兽
function c70284332.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 将这张卡（调律师的阴谋）破坏
function c70284332.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将自身（这张卡）破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

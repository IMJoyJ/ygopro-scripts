--SPYRAL MISSION－奪還
-- 效果：
-- 这张卡发动后，第3次的自己结束阶段破坏。
-- ①：1回合1次，自己场上有「秘旋谍」怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽在这个回合不能直接攻击。
-- ②：自己场上的「秘旋谍」怪兽被战斗·效果破坏的场合，可以作为那1只破坏的怪兽的代替而把墓地的这张卡除外。
function c39373426.initial_effect(c)
	-- 效果原文：这张卡发动后，第3次的自己结束阶段破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(39373426,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(c39373426.target)
	c:RegisterEffect(e0)
	-- 效果原文：①：1回合1次，自己场上有「秘旋谍」怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽在这个回合不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39373426,1))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c39373426.cncon)
	e1:SetCost(c39373426.cncost)
	e1:SetTarget(c39373426.cntg1)
	e1:SetOperation(c39373426.cnop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c39373426.cntg2)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己场上的「秘旋谍」怪兽被战斗·效果破坏的场合，可以作为那1只破坏的怪兽的代替而把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c39373426.reptg)
	e3:SetValue(c39373426.repval)
	e3:SetOperation(c39373426.repop)
	c:RegisterEffect(e3)
end
-- 执行操作：为卡片设置一个在自己结束阶段触发的计数器效果，用于记录发动后的结束阶段次数，当达到3次时触发破坏效果。
function c39373426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 效果原文：local e1=Effect.CreateEffect(c) e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE) e1:SetCode(EVENT_PHASE+PHASE_END) e1:SetCountLimit(1) e1:SetRange(LOCATION_SZONE) e1:SetCondition(c39373426.descon) e1:SetOperation(c39373426.desop) e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3) c:SetTurnCounter(0) c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c39373426.descon)
	e1:SetOperation(c39373426.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 规则层面：判断当前回合玩家是否为效果持有者
function c39373426.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面：当结束阶段触发时，增加计数器数值，若达到3则将此卡破坏
function c39373426.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 规则层面：将此卡以REASON_RULE原因破坏
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 规则层面：定义过滤器函数，用于筛选场上正面表示的「秘旋谍」怪兽
function c39373426.cncfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xee) and c:IsControler(tp)
end
-- 规则层面：判断是否有满足条件的「秘旋谍」怪兽被特殊召唤
function c39373426.cncon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39373426.cncfilter,1,nil,tp)
end
-- 规则层面：设置发动条件，确保每回合只能发动一次
function c39373426.cncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(39373426)==0 end
	e:GetHandler():RegisterFlagEffect(39373426,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 规则层面：设置目标选择函数，选择对方场上的怪兽作为控制权变更对象
function c39373426.cntg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 规则层面：检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面：提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 规则层面：选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 规则层面：设置连锁操作信息，表明将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	local c=e:GetHandler()
	-- 效果原文：local e1=Effect.CreateEffect(c) e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE) e1:SetCode(EVENT_PHASE+PHASE_END) e1:SetCountLimit(1) e1:SetRange(LOCATION_SZONE) e1:SetCondition(c39373426.descon) e1:SetOperation(c39373426.desop) e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3) c:SetTurnCounter(0) c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c39373426.descon)
	e1:SetOperation(c39373426.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 规则层面：设置目标选择函数，选择对方场上的怪兽作为控制权变更对象
function c39373426.cntg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 规则层面：检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面：提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 规则层面：选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 规则层面：设置连锁操作信息，表明将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 规则层面：执行控制权变更并附加不能直接攻击效果
function c39373426.cnop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面：判断目标怪兽是否有效且成功获得控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)>0 then
		-- 效果原文：local e1=Effect.CreateEffect(e:GetHandler()) e1:SetType(EFFECT_TYPE_SINGLE) e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE) e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK) e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) tc:RegisterEffect(e1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 规则层面：定义过滤器函数，用于筛选被战斗或效果破坏的「秘旋谍」怪兽
function c39373426.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xee) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 规则层面：判断是否可以发动代替破坏效果，并选择要代替破坏的怪兽
function c39373426.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c39373426.repfilter,1,nil,tp) end
	-- 规则层面：提示玩家选择是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c39373426.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 规则层面：提示玩家选择要代替破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 规则层面：返回指定怪兽是否为代替破坏对象
function c39373426.repval(e,c)
	return c==e:GetLabelObject()
end
-- 规则层面：将此卡从墓地除外
function c39373426.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：将此卡从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

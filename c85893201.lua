--連鎖誘爆
-- 效果：
-- 这张卡在场上存在，对方场上的怪兽被对方的卡的效果破坏的场合，可以选择场上1张卡破坏。这个效果1回合只能使用1次。
function c85893201.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡在场上存在，对方场上的怪兽被对方的卡的效果破坏的场合，可以选择场上1张卡破坏。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85893201,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c85893201.descon)
	e2:SetTarget(c85893201.destg)
	e2:SetOperation(c85893201.desop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的卡：原本存在于怪兽区、因效果被破坏、且原本控制者为对方的怪兽
function c85893201.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 判断发动条件：由对方卡片的效果导致对方场上的怪兽被破坏的场合
function c85893201.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c85893201.cfilter,1,nil,1-tp)
end
-- 效果的目标选择函数：检测并选择场上1张卡作为破坏的对象
function c85893201.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local exg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then exg=e:GetHandler() end
	-- 在发动阶段检测场上是否存在至少1张可选择的卡（排除未准备就绪的自身）
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exg) end
	-- 向发动效果的玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为该效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exg)
	-- 设置当前连锁的操作信息，表明将要破坏所选择的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理函数：获取对象卡片，若其仍符合条件则将其破坏
function c85893201.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

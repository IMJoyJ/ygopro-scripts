--共鳴破
-- 效果：
-- 只要这张卡在场上存在，每次名字带有「共鸣者」的怪兽作为同调素材送去墓地，选择对方场上存在的1张卡破坏。这张卡在发动后第2次的自己的结束阶段时破坏。
function c59593925.initial_effect(c)
	-- 这张卡在发动后第2次的自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c59593925.target)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，每次名字带有「共鸣者」的怪兽作为同调素材送去墓地，选择对方场上存在的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59593925,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c59593925.descon)
	e2:SetTarget(c59593925.destg)
	e2:SetOperation(c59593925.desop)
	c:RegisterEffect(e2)
	-- 这张卡在发动后第2次的自己的结束阶段时破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c59593925.sdescon)
	e3:SetOperation(c59593925.sdesop)
	c:RegisterEffect(e3)
end
-- 魔法卡发动时的效果处理，初始化这张卡的回合计数器为0
function c59593925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():SetTurnCounter(0)
end
-- 过滤送去墓地的卡是否为名字带有「共鸣者」的怪兽
function c59593925.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x57)
end
-- 触发条件：作为同调素材且有名字带有「共鸣者」的怪兽送去墓地
function c59593925.descon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and eg:IsExists(c59593925.cfilter,1,nil)
end
-- 破坏效果的靶向选择，选择对方场上存在的1张卡作为对象，并设置破坏的操作信息
function c59593925.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上存在的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表示该效果的处理为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理，若对象卡片仍存在于场上则将其破坏
function c59593925.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果原因破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 自我破坏效果的触发条件：当前回合玩家是自己
function c59593925.sdescon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为本方玩家（自己的结束阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 自我破坏效果的实际处理，增加回合计数器，并在达到第2次时将自身破坏
function c59593925.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 因规则原因破坏这张卡
		Duel.Destroy(c,REASON_RULE)
	end
end

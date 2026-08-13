--エヴォリューション・バースト
-- 效果：
-- 自己场上有「电子龙」表侧表示存在的场合才能发动。对方场上1张卡破坏。这张卡发动的回合「电子龙」不能攻击。
function c52875873.initial_effect(c)
	-- 自己场上有「电子龙」表侧表示存在的场合才能发动。对方场上1张卡破坏。这张卡发动的回合「电子龙」不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c52875873.condition)
	e1:SetCost(c52875873.cost)
	e1:SetTarget(c52875873.target)
	e1:SetOperation(c52875873.activate)
	c:RegisterEffect(e1)
	-- 注册一个攻击活动计数器，记录本回合是否进行过攻击，用于限制发动条件。
	Duel.AddCustomActivityCounter(52875873,ACTIVITY_ATTACK,c52875873.counterfilter)
end
-- 计数器过滤函数：只有非「电子龙」卡的攻击会计数，即「电子龙」的攻击不限制本卡发动。
function c52875873.counterfilter(c)
	return not c:IsCode(70095154)
end
-- 过滤条件：表侧表示且卡名为「电子龙」。
function c52875873.cfilter(c)
	return c:IsFaceup() and c:IsCode(70095154)
end
-- 发动条件判断：自己场上有表侧表示的「电子龙」存在。
function c52875873.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1张满足cfilter（表侧「电子龙」）的卡。
	return Duel.IsExistingMatchingCard(c52875873.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 代价函数：若本回合未进行过符合条件的攻击，则给自己场上的「电子龙」附加本回合不能攻击的誓约效果。
function c52875873.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否有过攻击计数（非「电子龙」攻击），若已有攻击则不能发动。
	if chk==0 then return Duel.GetCustomActivityCount(52875873,tp,ACTIVITY_ATTACK)==0 end
	-- 自己场上有「电子龙」表侧表示存在的场合才能发动。对方场上1张卡破坏。这张卡发动的回合「电子龙」不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 该不能攻击效果影响所有卡名为「电子龙」的卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,70095154))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的誓约效果注册到场上，持续到本回合结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 取对象效果的目标选择函数：选择对方场上1张卡作为破坏对象。
function c52875873.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 确认存在至少1张对方场上可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张卡作为对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定本次连锁的破坏操作信息，为破坏效果提供检测信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将对象卡破坏。
function c52875873.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 用效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

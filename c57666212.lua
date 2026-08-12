--光帝クライス
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时，以场上最多2张卡为对象才能发动。那些卡破坏，破坏的卡的控制者可以从卡组抽出破坏的数量。
-- ②：这张卡在召唤·特殊召唤的回合不能攻击。
function c57666212.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，以场上最多2张卡为对象才能发动。那些卡破坏，破坏的卡的控制者可以从卡组抽出破坏的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57666212,0))  --"把场上存在的最多2张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c57666212.target)
	e1:SetOperation(c57666212.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在召唤·特殊召唤的回合不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c57666212.disatt)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- ①号效果的发动准备：检查场上是否存在可作为对象的目标，并让玩家选择最多2张场上的卡作为对象，设置破坏的操作信息。
function c57666212.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以作为效果对象的目标。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择场上1到2张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置连锁操作信息，表明此效果的处理包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①号效果的处理：获取并过滤出仍存在于场上的对象卡，将其破坏，并分别统计双方玩家被破坏的卡片数量。
function c57666212.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 因效果破坏符合条件的卡片。
	Duel.Destroy(sg,REASON_EFFECT)
	-- 获取本次操作中实际被破坏的卡片组。
	sg=Duel.GetOperatedGroup()
	local d1=0
	local d2=0
	local tc=sg:GetFirst()
	while tc do
		if tc then
			if tc:IsPreviousControler(0) then d1=d1+1
			else d2=d2+1 end
		end
		tc=sg:GetNext()
	end
	-- 若先攻玩家（玩家0）有卡被破坏且可以抽卡，则由其选择是否抽出对应数量的卡。
	if d1>0 and Duel.IsPlayerCanDraw(0,d1) and Duel.SelectYesNo(0,aux.Stringid(57666212,1)) then Duel.Draw(0,d1,REASON_EFFECT) end  --"是否要抽卡？"
	-- 若后攻玩家（玩家1）有卡被破坏且可以抽卡，则由其选择是否抽出对应数量的卡。
	if d2>0 and Duel.IsPlayerCanDraw(1,d2) and Duel.SelectYesNo(1,aux.Stringid(57666212,1)) then Duel.Draw(1,d2,REASON_EFFECT) end  --"是否要抽卡？"
end
-- 召唤·特殊召唤成功时触发的辅助效果，为自身添加“本回合不能攻击”的限制。
function c57666212.disatt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡在召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

--刻印の調停者
-- 效果：
-- ①：对方把宣言1个卡名发动的效果发动时，把这张卡从手卡送去墓地才能发动。宣言1个卡名。对方宣言的卡名变成这个效果宣言的卡名。
-- ②：1回合1次，以场上1张表侧表示的卡为对象才能发动。下个回合的结束阶段把那张卡破坏。这个效果在对方回合也能发动。
function c50078320.initial_effect(c)
	-- ①：对方把宣言1个卡名发动的效果发动时，把这张卡从手卡送去墓地才能发动。宣言1个卡名。对方宣言的卡名变成这个效果宣言的卡名。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50078320.condition)
	e1:SetCost(c50078320.cost)
	e1:SetOperation(c50078320.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以场上1张表侧表示的卡为对象才能发动。下个回合的结束阶段把那张卡破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50078320,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c50078320.regtg)
	e2:SetOperation(c50078320.regop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：仅当对方（rp==1-tp）发动了带有宣言卡名类别（CATEGORY_ANNOUNCE）的效果时，这张卡才能从手牌发动。
function c50078320.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的操作信息中是否存在宣言卡名（CATEGORY_ANNOUNCE）的记录，用于判断是否满足发动条件。
	local ex=Duel.GetOperationInfo(ev,CATEGORY_ANNOUNCE)
	return rp==1-tp and ex
end
-- 代价处理：检查此卡能否从手牌送去墓地作为代价；能则实际执行送墓，完成发动代价。
function c50078320.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把此卡从手牌送去墓地，作为效果①的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：读取对方原宣言的卡名，让本方宣言另一个卡名（遵守对方效果自带的宣言限制），然后把连锁参数改成本方宣言的卡名，使对方宣言的卡名被替换。
function c50078320.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出对方发动的效果所宣言的卡名（存在CHAININFO_TARGET_PARAM中）。
	local code=Duel.GetChainInfo(ev,CHAININFO_TARGET_PARAM)
	local ac=0
	-- 给本方玩家显示宣言卡名的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	if re:GetHandler().announce_filter==nil then
		-- 让本方宣言一个卡名，且不能与对方原宣言的卡名相同（OPCODE_NOT排除code），返回宣言的卡号。
		ac=Duel.AnnounceCard(tp,code,OPCODE_ISCODE,OPCODE_NOT)
	else
		local afilter={table.unpack(re:GetHandler().announce_filter)}
		table.insert(afilter,code)
		table.insert(afilter,OPCODE_ISCODE)
		table.insert(afilter,OPCODE_NOT)
		table.insert(afilter,OPCODE_AND)
		-- 在对方效果的宣言过滤规则基础上追加不能宣言原卡名的限制，再让本方宣言，返回卡号。
		ac=Duel.AnnounceCard(tp,table.unpack(afilter))
	end
	-- 将对方那个连锁效果的目标参数改成本方宣言的卡名，从而把对方宣言的卡名变成这个效果宣言的卡名。
	Duel.ChangeTargetParam(ev,ac)
end
-- ②效果的对象筛选：只选择表侧表示的卡。
function c50078320.desfilter(c)
	return c:IsFaceup()
end
-- ②效果的发动指定：取场上1张表侧表示的卡为对象（取对象效果），并检查是否存在合法对象。
function c50078320.regtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c50078320.desfilter(chkc) end
	-- 发动合法性检查：场上是否存在至少1张表侧表示的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c50078320.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示本方玩家选择②效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1张表侧表示的卡作为对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c50078320.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果处理：给对象卡附加标记，并注册一个延迟效果，使对象卡在下个回合结束阶段被破坏。
function c50078320.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(50078320,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 下个回合的结束阶段把那张卡破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(50078320,1))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 记录发动时的回合数，用来判断是否已经到达“下个回合”。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		e1:SetCondition(c50078320.descon)
		e1:SetOperation(c50078320.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将延迟破坏效果注册到场上持续效果中，使其能在下个回合结束阶段自动结算。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟破坏的触发条件：到达发动后的下个回合结束阶段，且对象卡仍持有标记（尚未离场或重置）。
function c50078320.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 确认当前回合数已不等于发动时回合数（即已到下一个回合的结束阶段），并且对象卡上的标记仍存在，满足破坏条件。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(50078320)~=0
end
-- 破坏处理：在满足条件的结束阶段，将对象卡破坏。
function c50078320.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 向双方展示此卡（50078320）的卡图，作为效果处理提示。
	Duel.Hint(HINT_CARD,0,50078320)
	-- 以效果原因破坏对象卡。
	Duel.Destroy(tc,REASON_EFFECT)
end

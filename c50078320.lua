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
-- 判断是否为对方发动的宣言卡名的效果
function c50078320.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁是否包含宣言卡名的操作
	local ex=Duel.GetOperationInfo(ev,CATEGORY_ANNOUNCE)
	return rp==1-tp and ex
end
-- 支付将此卡送入墓地作为代价
function c50078320.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 处理效果①的宣言与替换逻辑
function c50078320.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方发动效果时的参数（即被宣言的卡号）
	local code=Duel.GetChainInfo(ev,CHAININFO_TARGET_PARAM)
	local ac=0
	-- 提示玩家进行卡名宣言
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	if re:GetHandler().announce_filter==nil then
		-- 在无过滤条件时直接宣言一个卡号
		ac=Duel.AnnounceCard(tp,code,OPCODE_ISCODE,OPCODE_NOT)
	else
		local afilter={table.unpack(re:GetHandler().announce_filter)}
		table.insert(afilter,code)
		table.insert(afilter,OPCODE_ISCODE)
		table.insert(afilter,OPCODE_NOT)
		table.insert(afilter,OPCODE_AND)
		-- 根据原效果的过滤条件组合新的过滤器并进行宣言
		ac=Duel.AnnounceCard(tp,table.unpack(afilter))
	end
	-- 将连锁参数替换为新宣言的卡号
	Duel.ChangeTargetParam(ev,ac)
end
-- 判断对象是否为表侧表示的场上卡片
function c50078320.desfilter(c)
	return c:IsFaceup()
end
-- 处理效果②的选择目标与设置
function c50078320.regtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c50078320.desfilter(chkc) end
	-- 检查是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c50078320.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个满足条件的场上卡片作为对象
	Duel.SelectTarget(tp,c50078320.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 处理效果②的发动与后续破坏设定
function c50078320.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(50078320,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 注册一个在结束阶段触发的持续效果用于破坏目标卡片
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(50078320,1))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 记录当前回合数以供后续判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		e1:SetCondition(c50078320.descon)
		e1:SetOperation(c50078320.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将该持续效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否到了下个回合的结束阶段且目标卡片仍存在
function c50078320.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断回合数已改变且目标卡片有标记
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(50078320)~=0
end
-- 执行破坏操作
function c50078320.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 显示此卡被破坏的动画提示
	Duel.Hint(HINT_CARD,0,50078320)
	-- 以效果原因将目标卡片破坏
	Duel.Destroy(tc,REASON_EFFECT)
end

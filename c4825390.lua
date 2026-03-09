--イチロクの魔物台帳
-- 效果：
-- ①：以对方场上最多2只怪兽为对象才能发动。那些怪兽直到结束阶段除外。那之后，对方回复这个效果从场上离开的怪兽数量×1000基本分。
local s,id,o=GetID()
-- 创建并注册卡片效果，设置为发动时点、可选对象、除外与回复类别
function s.initial_effect(c)
	-- ①：以对方场上最多2只怪兽为对象才能发动。那些怪兽直到结束阶段除外。那之后，对方回复这个效果从场上离开的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 处理效果目标选择，判断是否能选择对方场上的怪兽作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查是否满足发动条件，即对方场上是否存在可除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1到2只对方场上的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,2,nil)
	-- 设置效果操作信息，记录将要除外的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 执行效果处理流程，包括除外怪兽、设置返回场上的效果、回复LP
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡片组，并筛选出与当前效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 以效果和暂时除外原因将目标怪兽除外
	if Duel.Remove(tg,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 获取实际被操作的卡片组
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 创建并注册结束阶段返回场上的持续效果，用于处理除外怪兽在结束阶段返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(s.retop)
		-- 将创建的效果注册给对应玩家
		Duel.RegisterEffect(e1,tp)
		-- 中断当前连锁处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 使对方回复因效果除外的怪兽数量乘以1000的基本分
		Duel.Recover(1-tp,#og*1000,REASON_EFFECT)
	end
end
-- 定义筛选函数，用于判断卡片是否具有指定标记效果
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
-- 处理结束阶段返回场上的逻辑，根据场上空位数量决定是否选择性返回
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	-- 判断返回场上的怪兽数量大于1且对方场上只有一个空位时触发选择机制
	if sg:GetCount()>1 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)==1 then
		-- 向玩家提示选择要回到场上的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要回到场上的怪兽"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 将选中的怪兽返回场上
		Duel.ReturnToField(tc)
	else
		local tc=sg:GetFirst()
		while tc do
			-- 将剩余的怪兽依次返回场上
			Duel.ReturnToField(tc)
			tc=sg:GetNext()
		end
	end
end

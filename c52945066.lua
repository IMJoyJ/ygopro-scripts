--海晶乙女波動
-- 效果：
-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上有「海晶少女」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。自己场上有连接2以上的「海晶少女」怪兽存在的场合，再让自己场上的全部表侧表示怪兽直到回合结束时不受对方的效果影响。
function c52945066.initial_effect(c)
	-- ①：自己场上有「海晶少女」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。自己场上有连接2以上的「海晶少女」怪兽存在的场合，再让自己场上的全部表侧表示怪兽直到回合结束时不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c52945066.con)
	e1:SetTarget(c52945066.target)
	e1:SetOperation(c52945066.activate)
	c:RegisterEffect(e1)
	-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52945066,0))  --"适用「海晶少女波动」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c52945066.handcon)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上表侧表示的海晶少女连接怪兽
function c52945066.ccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
-- 效果条件：检查自己场上是否存在海晶少女连接怪兽
function c52945066.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在海晶少女连接怪兽
	return Duel.IsExistingMatchingCard(c52945066.ccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果目标：选择对方场上一只可被无效化的怪兽作为对象
function c52945066.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否为效果目标的过滤条件：对方场上表侧表示的怪兽且未被无效化
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 判断是否能发动此效果：对方场上是否存在可被无效化的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上一只可被无效化的怪兽作为对象
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 过滤函数，用于筛选场上表侧表示且连接值大于等于2的海晶少女怪兽
function c52945066.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(2)
end
-- 效果发动处理：使目标怪兽效果无效并使其在回合结束时不受对方效果影响
function c52945066.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化（持续到回合结束）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 获取自己场上所有表侧表示的怪兽
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		-- 检查自己场是否同时存在连接2以上的海晶少女怪兽且自己场上存在表侧表示怪兽
		if Duel.IsExistingMatchingCard(c52945066.cfilter,tp,LOCATION_MZONE,0,1,nil) and g1:GetCount()>0 then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			local nc=g1:GetFirst()
			while nc do
				-- 使己方场上所有表侧表示怪兽在回合结束前免疫对方的效果
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetRange(LOCATION_MZONE)
				e3:SetCode(EFFECT_IMMUNE_EFFECT)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e3:SetValue(c52945066.efilter)
				e3:SetOwnerPlayer(tp)
				nc:RegisterEffect(e3)
				nc=g1:GetNext()
			end
		end
	end
end
-- 效果过滤函数：判断效果来源是否为对方
function c52945066.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 过滤函数，用于筛选场上表侧表示且连接值大于等于3的海晶少女怪兽
function c52945066.hcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(3)
end
-- 手牌发动条件：检查自己场上是否存在连接3以上的海晶少女怪兽
function c52945066.handcon(e)
	-- 检查自己场上是否存在连接3以上的海晶少女怪兽
	return Duel.IsExistingMatchingCard(c52945066.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

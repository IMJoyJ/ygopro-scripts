--ゴーストリック・オア・トリート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「鬼计」场地魔法卡或者「鬼计」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。对方可以支付2000基本分。那个场合，这张卡的效果变成「发动后这张卡不送去墓地，直接盖放」。没支付的场合，这个回合，那只表侧表示怪兽不能攻击，效果无效化，结束阶段变成里侧守备表示。
function c27170599.initial_effect(c)
	-- 创建效果对象，设置效果类别为无效化、改变表示形式、盖放，类型为发动效果，代码为自由时点，具有取对象属性，发动次数限制为1次，提示时点为怪兽正面上场和结束阶段，条件为己方场上有鬼计场地魔法或鬼计连接怪兽，目标为对方场上表侧表示怪兽，效果处理为operation函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,27170599+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c27170599.condition)
	e1:SetTarget(c27170599.target)
	e1:SetOperation(c27170599.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查己方场上的卡是否为鬼计系列且表侧表示
function c27170599.confilter1(c)
	return c:IsSetCard(0x8d) and c:IsFaceup()
end
-- 过滤函数，检查己方场上的卡是否为鬼计系列且为连接怪兽
function c27170599.confilter2(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_LINK)
end
-- 条件函数，判断己方场上有鬼计场地魔法或鬼计连接怪兽
function c27170599.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场地上是否存在至少1张鬼计系列的表侧表示卡
	return Duel.IsExistingMatchingCard(c27170599.confilter1,tp,LOCATION_FZONE,0,1,nil)
		-- 或检查己方主要怪兽区是否存在至少1张鬼计系列的连接怪兽
		or Duel.IsExistingMatchingCard(c27170599.confilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标函数，设置选择对方场上表侧表示怪兽为目标，检查是否有满足条件的怪兽，提示选择表侧表示的怪兽并选择目标
function c27170599.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否有满足条件的对方场上表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，根据是否支付2000基本分决定效果处理方式，支付则不送去墓地直接盖放，未支付则该怪兽本回合不能攻击、效果无效化并在结束阶段变为里侧守备表示
function c27170599.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		local sel=1
		-- 提示玩家选择是否支付2000基本分
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27170599,0))  --"是否支付基本分？"
		-- 检查对方是否能支付2000基本分并可盖放此卡
		if c:IsRelateToEffect(e) and c:IsCanTurnSet() and Duel.CheckLPCost(1-tp,2000) then
			-- 让对方选择是否支付2000基本分
			sel=Duel.SelectOption(1-tp,1213,1214)
		end
		if sel==0 then
			-- 对方支付2000基本分
			Duel.PayLPCost(1-tp,2000)
			if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
				-- 中断当前效果处理，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				c:CancelToGrave()
				-- 将此卡变为里侧表示
				Duel.ChangePosition(c,POS_FACEDOWN)
				-- 触发放置魔陷的时点事件
				Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			end
		else
			-- 给目标怪兽添加不能攻击的效果，持续到结束阶段
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if not c:IsDisabled() then
				-- 使目标怪兽相关的连锁无效化
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 给目标怪兽添加效果无效化的效果，持续到结束阶段
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
				-- 给目标怪兽添加效果无效化的效果，持续到结束阶段
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				e3:SetValue(RESET_TURN_SET)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(27170599,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 注册一个在结束阶段触发的效果，用于将目标怪兽变为里侧守备表示
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_PHASE+PHASE_END)
			e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetCountLimit(1)
			e4:SetLabel(fid)
			e4:SetLabelObject(tc)
			e4:SetCondition(c27170599.flipcon)
			e4:SetOperation(c27170599.flipop)
			-- 将结束阶段触发的效果注册给玩家
			Duel.RegisterEffect(e4,tp)
		end
	end
end
-- 结束阶段触发效果的条件函数，判断目标怪兽是否仍处于该效果的控制下
function c27170599.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(27170599)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段触发效果的处理函数，将目标怪兽变为里侧守备表示
function c27170599.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽变为里侧守备表示
	Duel.ChangePosition(e:GetLabelObject(),POS_FACEDOWN_DEFENSE)
end

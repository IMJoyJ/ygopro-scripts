--ゴーストリック・オア・トリート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「鬼计」场地魔法卡或者「鬼计」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。对方可以支付2000基本分。那个场合，这张卡的效果变成「发动后这张卡不送去墓地，直接盖放」。没支付的场合，这个回合，那只表侧表示怪兽不能攻击，效果无效化，结束阶段变成里侧守备表示。
function c27170599.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「鬼计」场地魔法卡或者「鬼计」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。对方可以支付2000基本分。那个场合，这张卡的效果变成「发动后这张卡不送去墓地，直接盖放」。没支付的场合，这个回合，那只表侧表示怪兽不能攻击，效果无效化，结束阶段变成里侧守备表示。
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
-- 过滤「鬼计」场地魔法卡：表侧表示且属于「鬼计」字段的卡（调用位置限定在己方场地区）。
function c27170599.confilter1(c)
	return c:IsSetCard(0x8d) and c:IsFaceup()
end
-- 过滤「鬼计」连接怪兽：属于「鬼计」字段且为连接怪兽（连接怪兽必定表侧表示，故无需额外判定表侧）。
function c27170599.confilter2(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_LINK)
end
-- 发动条件：己方场上有「鬼计」场地魔法卡或「鬼计」连接怪兽存在时才能发动。
function c27170599.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场地区是否存在至少1张表侧表示的「鬼计」场地魔法卡。
	return Duel.IsExistingMatchingCard(c27170599.confilter1,tp,LOCATION_FZONE,0,1,nil)
		-- 检查己方怪兽区是否存在至少1只「鬼计」连接怪兽。
		or Duel.IsExistingMatchingCard(c27170599.confilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 取对象条件定义：必须以对方场上1只表侧表示怪兽为对象；在效果发动时从对方怪兽区选择1只表侧表示怪兽。
function c27170599.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动前判定：确认对方场上存在至少1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际从对方场上选择1只表侧表示怪兽作为本卡的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：先让对方选择是否支付2000基本分；支付则本卡不送墓直接盖放；不支付则对象本回合不能攻击、效果无效化，并在结束阶段变为里侧守备表示。
function c27170599.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出本卡效果的对象（对方场上那只表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		local sel=1
		-- 提示当前玩家（对方）选择是否支付基本分。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27170599,0))  --"是否支付基本分？"
		-- 判定本卡仍与效果关联、本卡能盖放且对方能支付2000LP时，才允许对方选择支付/不支付。
		if c:IsRelateToEffect(e) and c:IsCanTurnSet() and Duel.CheckLPCost(1-tp,2000) then
			-- 让对方从“支付”和“不支付”两个选项中作出选择，sel=0为支付，sel=1为不支付。
			sel=Duel.SelectOption(1-tp,1213,1214)
		end
		if sel==0 then
			-- 对方支付2000基本分。
			Duel.PayLPCost(1-tp,2000)
			if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
				-- 中断当前效果链，使之后的处理（盖放）作为另一次处理进行，与之前的处理不在同一时点。
				Duel.BreakEffect()
				c:CancelToGrave()
				-- 由于对方支付了LP，本卡不送去墓地，直接变成里侧守备表示（盖放）。
				Duel.ChangePosition(c,POS_FACEDOWN)
				-- 触发“魔法陷阱卡被盖放”的时点，通知系统本卡以里侧表示放置到了魔法陷阱区。
				Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			end
		else
			-- 这个回合，那只表侧表示怪兽不能攻击
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if not c:IsDisabled() then
				-- 使与对象怪兽相关的连锁效果全部无效化，并持续到回合结束时重置。
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 效果无效化（使对象怪兽的卡上效果无效）
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
				-- 效果无效化（使对象怪兽发动的效果无效化）
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				e3:SetValue(RESET_TURN_SET)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(27170599,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 结束阶段变成里侧守备表示（并在结束阶段由后续函数执行翻转）
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_PHASE+PHASE_END)
			e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetCountLimit(1)
			e4:SetLabel(fid)
			e4:SetLabelObject(tc)
			e4:SetCondition(c27170599.flipcon)
			e4:SetOperation(c27170599.flipop)
			-- 将结束阶段翻转的持续效果注册到全场，使该效果在结束阶段时执行。
			Duel.RegisterEffect(e4,tp)
		end
	end
end
-- 翻转效果的发动条件：仅在对象怪兽仍持有对应标记（即仍存在且未离场/重置）时才执行翻转；否则重置该效果。
function c27170599.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(27170599)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时执行的翻转操作：将对象怪兽变成里侧守备表示。
function c27170599.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行把对象怪兽的表示形式变更为里侧守备表示。
	Duel.ChangePosition(e:GetLabelObject(),POS_FACEDOWN_DEFENSE)
end

--海造賊－大航海
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：宣言1个属性，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的属性。那之后，可以从自己墓地选1只「海造贼」怪兽回到卡组或特殊召唤。
-- ②：自己·对方的结束阶段，「海造贼」怪兽不在自己场上存在的场合发动。这张卡送去墓地。
function c20426176.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：宣言1个属性，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的属性。那之后，可以从自己墓地选1只「海造贼」怪兽回到卡组或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20426176,0))  --"改变属性"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,20426176)
	e2:SetTarget(c20426176.atrtg)
	e2:SetOperation(c20426176.atrop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段，「海造贼」怪兽不在自己场上存在的场合发动。这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20426176,1))  --"这张卡送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c20426176.tgcon)
	e3:SetTarget(c20426176.tgtg)
	e3:SetOperation(c20426176.tgop)
	c:RegisterEffect(e3)
end
-- 选择对方场上1只表侧表示怪兽作为效果对象
function c20426176.atrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家宣言属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- 过滤满足条件的「海造贼」怪兽，可以回到卡组或特殊召唤
function c20426176.thfilter(c,e,tp,ft)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 将目标怪兽属性更改为宣言的属性，并询问是否从墓地选择「海造贼」怪兽特殊召唤或送回卡组
function c20426176.atrop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	local att=e:GetLabel()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and not tc:IsAttribute(att) then
		-- 将目标怪兽的属性更改为宣言的属性
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查玩家墓地是否存在满足条件的「海造贼」怪兽，并询问是否选择
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c20426176.thfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) and Duel.SelectYesNo(tp,aux.Stringid(20426176,2)) then  --"是否选怪兽回到卡组或特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要送回卡组或特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
			-- 从玩家墓地中选择1只满足条件的「海造贼」怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20426176.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
			local sc=g:GetFirst()
			if ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 如果怪兽不能送回卡组，则选择特殊召唤
				and (not sc:IsAbleToDeck() or Duel.SelectOption(tp,aux.Stringid(20426176,3),1152)==1) then  --"回到卡组"
				-- 将选中的怪兽特殊召唤到场上
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 显示选中的怪兽被选为对象的动画效果
				Duel.HintSelection(g)
				-- 将选中的怪兽送回卡组
				Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
-- 过滤场上存在的「海造贼」怪兽
function c20426176.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 判断场上是否不存在「海造贼」怪兽
function c20426176.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场上不存在「海造贼」怪兽
	return not Duel.IsExistingMatchingCard(c20426176.tgfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时要送入墓地的卡
function c20426176.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要送入墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 将自身送入墓地
function c20426176.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end

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
	-- 这个卡名的①的效果1回合只能使用1次。①：宣言1个属性，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的属性。那之后，可以从自己墓地选1只「海造贼」怪兽回到卡组或特殊召唤。
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
-- ①效果的发动条件和发动时处理：先检查能否以对方场上表侧表示怪兽为对象；能发动时选择1只对象怪兽，并宣言1个不能与对象怪兽当前属性相同的属性，将宣言属性存入效果标签供后续使用。
function c20426176.atrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 效果发动时（chk==0）检查对方场上是否存在至少1只表侧表示且能成为效果对象的怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择对象的提示信息，使后续选择卡片时显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择1只表侧表示怪兽作为效果对象，并自动将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向玩家发送宣言属性的提示信息，使后续选择属性时显示“请选择要宣言的属性”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性，可选范围为全部属性除去对象怪兽当前属性；将宣言的属性保存到效果标签中，用于后续改变属性。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- 定义墓地可选「海造贼」怪兽的过滤条件：必须为「海造贼」系列怪兽，且要么能够回到卡组，要么在玩家有可用怪兽区时能够被特殊召唤。
function c20426176.thfilter(c,e,tp,ft)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的实际处理：将对象怪兽属性变为宣言属性直到回合结束；之后若墓地存在符合条件的「海造贼」怪兽，则询问玩家是否进行后续处理，选是后从墓地选择1只「海造贼」怪兽，在可特殊召唤的情况下由玩家选择回到卡组或特殊召唤，否则将其回到卡组。
function c20426176.atrop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此效果发动时选择的对象怪兽（即对方场上那只表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	local att=e:GetLabel()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and not tc:IsAttribute(att) then
		-- 那只怪兽直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 获取玩家tp当前主要怪兽区可用的空格数，用于判断后续能否从墓地特殊召唤怪兽。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查墓地是否存在1张以上符合条件的「海造贼」怪兽（排除受王家长眠之谷影响的卡），若存在则询问玩家“是否选怪兽回到卡组或特殊召唤？”来决定是否进行后续处理。
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c20426176.thfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) and Duel.SelectYesNo(tp,aux.Stringid(20426176,2)) then  --"是否选怪兽回到卡组或特殊召唤？"
			-- 中断当前效果处理，使后续的“回到卡组或特殊召唤”部分与前面的属性变更视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 向玩家发送“请选择”的提示信息，准备从墓地选择卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
			-- 让玩家从自己墓地选择1张符合条件的「海造贼」怪兽（过滤掉受王家长眠之谷影响的卡），选中结果存入g。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20426176.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
			local sc=g:GetFirst()
			if ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判断对选中怪兽采用特殊召唤还是回到卡组：若该怪兽不能回到卡组，或玩家在弹出的选项中选择“特殊召唤”（第二个选项），则满足特殊召唤分支；否则执行回到卡组。
				and (not sc:IsAbleToDeck() or Duel.SelectOption(tp,aux.Stringid(20426176,3),1152)==1) then  --"回到卡组"
				-- 将选中的「海造贼」怪兽以表侧表示特殊召唤到玩家tp的场上。
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 手动为选中的卡显示被选为对象的动画，并向双方展示这次选择。
				Duel.HintSelection(g)
				-- 将选中的「海造贼」怪兽以效果原因送回持有者卡组，并标记需要洗切卡组。
				Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
-- 定义检查场上是否存在「海造贼」怪兽的过滤条件：表侧表示且属于「海造贼」系列。
function c20426176.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- ②效果的发动条件判断：若自己场上不存在表侧表示的「海造贼」怪兽，则满足发动条件。
function c20426176.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「海造贼」怪兽，若不存在则返回true，即②效果可以发动。
	return not Duel.IsExistingMatchingCard(c20426176.tgfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动目标设定：发动时无条件允许（chk==0返回true），并将操作信息设置为把这张卡送去墓地。
function c20426176.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：本效果处理时会将这张卡送去墓地，供其他卡进行效果响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：若这张卡仍然与效果相关（仍在场上），就将其送去墓地。
function c20426176.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以效果原因送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end

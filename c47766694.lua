--荒野の大竜巻
-- 效果：
-- ①：以魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张表侧表示的卡破坏。那之后，破坏的卡的控制者可以从手卡把1张魔法·陷阱卡盖放。
-- ②：盖放的这张卡被破坏送去墓地的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
function c47766694.initial_effect(c)
	-- ①：以魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张表侧表示的卡破坏。那之后，破坏的卡的控制者可以从手卡把1张魔法·陷阱卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47766694.target)
	e1:SetOperation(c47766694.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被破坏送去墓地的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47766694,1))  --"表侧表示的1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c47766694.descon)
	e2:SetTarget(c47766694.destg)
	e2:SetOperation(c47766694.desop)
	c:RegisterEffect(e2)
end
-- 判断卡是否为表侧表示且位于魔法与陷阱区域（非场地格，序号<5）。
function c47766694.filter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 效果①发动时的目标处理：确认存在符合条件的取对象候选，选择魔法与陷阱区1张表侧表示的非自身卡为对象，并设置破坏操作信息。
function c47766694.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c47766694.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动合法性检查：己方或对方魔法与陷阱区域存在1张表侧表示且不是本卡的可选对象时才能发动。
	if chk==0 then return Duel.IsExistingTarget(c47766694.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方的魔法与陷阱区域选择1张表侧表示且不是本卡的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c47766694.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	-- 登记本次连锁将破坏1张卡的操作信息，供相关效果判定用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的解决处理：若对象仍合法则将其破坏；破坏成功后，由该卡控制者选择是否从手卡盖放1张魔法·陷阱卡。
function c47766694.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①选择的那个对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在场上表侧表示且与效果关联，然后将其破坏；仅当破坏处理实际成功时才继续后续盖放流程。
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local dp=tc:GetControler()
		-- 获取对象卡控制者手牌中所有可以盖放的魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(Card.IsSSetable,dp,LOCATION_HAND,0,nil)
		-- 若存在可盖放的卡，则询问该玩家是否要盖放；玩家选择“是”时继续。
		if g:GetCount()>0 and Duel.SelectYesNo(dp,aux.Stringid(47766694,0)) then  --"是否要放置魔法或陷阱卡？"
			-- 中断当前效果链，使后续盖放处理视为另一段效果处理，以错开时点并可被连锁。
			Duel.BreakEffect()
			-- 显示“请选择要盖放的卡”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(dp,1,1,nil)
			-- 将从手牌选出的魔法·陷阱卡以里侧表示盖放到该玩家自己的魔法与陷阱区域。
			Duel.SSet(dp,sg,dp,false)
		end
	end
end
-- 效果②的触发条件：本卡以里侧表示存在于场上时被破坏并送去墓地（破坏原因成立且此前位置在场上、此前表示为里侧）。
function c47766694.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 效果②的取对象过滤：选择场上表侧表示的卡。
function c47766694.desfilter(c)
	return c:IsFaceup()
end
-- 效果②发动时的目标处理：选择场上1张表侧表示的卡为对象，并设置破坏操作信息。
function c47766694.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c47766694.desfilter(chkc) end
	if chk==0 then return true end
	-- 显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张表侧表示的卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,c47766694.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁将破坏1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的解决处理：破坏所选对象。
function c47766694.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

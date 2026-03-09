--荒野の大竜巻
-- 效果：
-- ①：以魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张表侧表示的卡破坏。那之后，破坏的卡的控制者可以从手卡把1张魔法·陷阱卡盖放。
-- ②：盖放的这张卡被破坏送去墓地的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
function c47766694.initial_effect(c)
	-- 效果原文内容：①：以魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张表侧表示的卡破坏。那之后，破坏的卡的控制者可以从手卡把1张魔法·陷阱卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47766694.target)
	e1:SetOperation(c47766694.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：盖放的这张卡被破坏送去墓地的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
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
-- 规则层面作用：过滤满足条件的魔法与陷阱区域的表侧表示的卡（序列号小于5）
function c47766694.filter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 规则层面作用：设置效果目标为魔法与陷阱区域的表侧表示的卡
function c47766694.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c47766694.filter(chkc) and chkc~=e:GetHandler() end
	-- 规则层面作用：判断是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c47766694.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 规则层面作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择一个魔法与陷阱区域的表侧表示的卡作为目标
	local g=Duel.SelectTarget(tp,c47766694.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	-- 规则层面作用：设置操作信息，确定要破坏的卡的数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：处理效果发动后的操作，包括破坏目标卡并询问是否盖放魔法或陷阱卡
function c47766694.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标卡是否满足破坏条件（表侧表示、存在于场上、与效果相关）
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local dp=tc:GetControler()
		-- 规则层面作用：获取破坏卡的控制者手牌中可以盖放的魔法或陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsSSetable,dp,LOCATION_HAND,0,nil)
		-- 规则层面作用：询问破坏卡的控制者是否要盖放一张魔法或陷阱卡
		if g:GetCount()>0 and Duel.SelectYesNo(dp,aux.Stringid(47766694,0)) then  --"是否要放置魔法或陷阱卡？"
			-- 规则层面作用：中断当前效果处理，使后续操作不同时处理
			Duel.BreakEffect()
			-- 规则层面作用：提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(dp,1,1,nil)
			-- 规则层面作用：将选中的卡盖放到场上
			Duel.SSet(dp,sg,dp,false)
		end
	end
end
-- 规则层面作用：判断该卡是否因破坏而进入墓地且处于背面表示状态
function c47766694.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 规则层面作用：过滤满足条件的场上表侧表示的卡
function c47766694.desfilter(c)
	return c:IsFaceup()
end
-- 规则层面作用：设置触发效果的目标为场上的表侧表示的卡
function c47766694.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c47766694.desfilter(chkc) end
	if chk==0 then return true end
	-- 规则层面作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择一个场上的表侧表示的卡作为目标
	local g=Duel.SelectTarget(tp,c47766694.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面作用：设置操作信息，确定要破坏的卡的数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：处理触发效果的后续操作，即破坏目标卡
function c47766694.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面作用：以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

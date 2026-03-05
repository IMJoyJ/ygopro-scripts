--超重武者ヌス－10
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：可以把这张卡解放，从以下效果选择1个发动。
-- ●选对方的魔法与陷阱区域1张卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。
-- ●选对方的灵摆区域1张卡破坏。那之后，可以把破坏的那张卡在自己的灵摆区域放置。
function c14756848.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14756848,0))  --"·。·"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14756848.hspcon)
	e1:SetOperation(c14756848.hspop)
	c:RegisterEffect(e1)
	-- ②：可以把这张卡解放，从以下效果选择1个发动。●选对方的魔法与陷阱区域1张卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。●选对方的灵摆区域1张卡破坏。那之后，可以把破坏的那张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c14756848.descost)
	e2:SetTarget(c14756848.destg)
	e2:SetOperation(c14756848.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断卡片是否为魔法或陷阱类型
function c14756848.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断特殊召唤条件是否满足，即自己场上存在空位且墓地没有魔法或陷阱卡
function c14756848.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家的怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在魔法或陷阱卡
		and not Duel.IsExistingMatchingCard(c14756848.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤成功后的处理函数，用于设置不能特殊召唤的效果
function c14756848.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c14756848.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止召唤非超重武者怪兽
function c14756848.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- 支付效果cost的函数，解放自身作为cost
function c14756848.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果的cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于判断卡片是否在魔法与陷阱区域
function c14756848.desfilter1(c)
	return c:GetSequence()<5
end
-- 设置效果目标的函数，用于选择发动效果的选项
function c14756848.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sel=0
		-- 检查对方魔法与陷阱区域是否存在卡
		if Duel.IsExistingMatchingCard(c14756848.desfilter1,tp,0,LOCATION_SZONE,1,nil) then sel=sel+1 end
		-- 检查对方灵摆区域是否存在卡
		if Duel.GetFieldGroupCount(tp,0,LOCATION_PZONE)>0 then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		-- 选择发动效果的选项，选择破坏对方魔法与陷阱区域的卡
		sel=Duel.SelectOption(tp,aux.Stringid(14756848,1),aux.Stringid(14756848,2))+1  --"对方的魔法与陷阱区域1张卡破坏"
	elseif sel==1 then
		-- 选择发动效果的选项，选择破坏对方魔法与陷阱区域的卡
		Duel.SelectOption(tp,aux.Stringid(14756848,1))  --"对方的魔法与陷阱区域1张卡破坏"
	else
		-- 选择发动效果的选项，选择破坏对方灵摆区域的卡
		Duel.SelectOption(tp,aux.Stringid(14756848,2))  --"选对方的灵摆区域1张卡破坏"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
		-- 获取对方魔法与陷阱区域满足条件的卡组
		local g=Duel.GetMatchingGroup(c14756848.desfilter1,tp,0,LOCATION_SZONE,nil)
		-- 设置连锁操作信息，指定要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取对方灵摆区域的卡组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_PZONE)
		-- 设置连锁操作信息，指定要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 执行效果处理的函数
function c14756848.desop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择对方魔法与陷阱区域的卡
		local g=Duel.SelectMatchingCard(tp,c14756848.desfilter1,tp,0,LOCATION_SZONE,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的卡并检查是否有足够的空位
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK)
			and tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable()
			-- 询问玩家是否将破坏的魔法或陷阱卡盖放
			and Duel.SelectYesNo(tp,aux.Stringid(14756848,3)) then  --"把破坏的那张魔法·陷阱卡在自己场上盖放？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将破坏的魔法或陷阱卡盖放
			Duel.SSet(tp,tc)
		end
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择对方灵摆区域的卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_PZONE):Select(tp,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的卡
		if Duel.Destroy(g,REASON_EFFECT)~=0
			-- 检查玩家灵摆区域是否有空位
			and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK) and not tc:IsForbidden()
			-- 询问玩家是否将破坏的卡放置在灵摆区域
			and Duel.SelectYesNo(tp,aux.Stringid(14756848,4)) then  --"把破坏的那张卡在自己的灵摆区域放置？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将破坏的卡移动到玩家的灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

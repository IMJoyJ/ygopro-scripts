--超重武者ヌス－10
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：可以把这张卡解放，从以下效果选择1个发动。
-- ●选对方的魔法与陷阱区域1张卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。
-- ●选对方的灵摆区域1张卡破坏。那之后，可以把破坏的那张卡在自己的灵摆区域放置。
function c14756848.initial_effect(c)
	-- 对应效果原文①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14756848,0))  --"·。·"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14756848.hspcon)
	e1:SetOperation(c14756848.hspop)
	c:RegisterEffect(e1)
	-- 对应效果原文②：可以把这张卡解放，从以下效果选择1个发动。●选对方的魔法与陷阱区域1张卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。●选对方的灵摆区域1张卡破坏。那之后，可以把破坏的那张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c14756848.descost)
	e2:SetTarget(c14756848.destg)
	e2:SetOperation(c14756848.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定卡片是否为魔法·陷阱卡，用于检查自己墓地是否存在魔法·陷阱卡。
function c14756848.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤规则效果的发动条件：自己墓地没有魔法·陷阱卡存在，且自己主要怪兽区域有空位。
function c14756848.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区域是否有可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地不存在魔法·陷阱卡（通过c14756848.filter过滤魔法陷阱卡，存在1张即不满足）。
		and not Duel.IsExistingMatchingCard(c14756848.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤成功时给发动玩家附加誓约效果：这个回合不能特殊召唤「超重武者」以外的怪兽。
function c14756848.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文中的“这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。”以及②“可以把这张卡解放，从以下效果选择1个发动。●选对方的魔法与陷阱区域1张卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。●选对方的灵摆区域1张卡破坏。那之后，可以把破坏的那张卡在自己的灵摆区域放置。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c14756848.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述“不能特殊召唤非超重武者”的限制效果注册给发动该效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：只有卡名属于「超重武者」的怪兽才能被特殊召唤。
function c14756848.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- ②效果的发动代价：解放自身（检查能否解放并在发动时支付）。
function c14756848.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选对方魔陷区中主要魔法与陷阱区域的卡（sequence<5，即排除场地魔法区域），作为可被破坏的魔陷卡。
function c14756848.desfilter1(c)
	return c:GetSequence()<5
end
-- ②效果发动时的目标选择：根据对方场上存在的可选破坏区域（魔陷区/灵摆区），让玩家选择其中一个，并设置对应的破坏类别和操作信息。
function c14756848.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sel=0
		-- 检测对方主要魔法与陷阱区域是否存在可破坏的卡，若存在则标记选项1（破坏魔陷区）可用。
		if Duel.IsExistingMatchingCard(c14756848.desfilter1,tp,0,LOCATION_SZONE,1,nil) then sel=sel+1 end
		-- 检测对方灵摆区域是否存在卡，若存在则标记选项2（破坏灵摆区）可用。
		if Duel.GetFieldGroupCount(tp,0,LOCATION_PZONE)>0 then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		-- 当两个区域都有可选卡时，让玩家选择要破坏的区域，并将选择结果存入效果标签（1=魔陷区，2=灵摆区）。
		sel=Duel.SelectOption(tp,aux.Stringid(14756848,1),aux.Stringid(14756848,2))+1  --"对方的魔法与陷阱区域1张卡破坏/选对方的灵摆区域1张卡破坏"
	elseif sel==1 then
		-- 当只有魔陷区可选时，直接选择破坏魔陷区（仅调用选项以匹配发动操作）。
		Duel.SelectOption(tp,aux.Stringid(14756848,1))  --"对方的魔法与陷阱区域1张卡破坏"
	else
		-- 当只有灵摆区可选时，直接选择破坏灵摆区（仅调用选项以匹配发动操作）。
		Duel.SelectOption(tp,aux.Stringid(14756848,2))  --"选对方的灵摆区域1张卡破坏"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
		-- 获取对方主要魔法与陷阱区域的全部卡，作为可能被破坏的对象组。
		local g=Duel.GetMatchingGroup(c14756848.desfilter1,tp,0,LOCATION_SZONE,nil)
		-- 设置操作信息：本次效果预定破坏1张对方魔陷区的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取对方灵摆区域的全部卡，作为可能被破坏的对象组。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_PZONE)
		-- 设置操作信息：本次效果预定破坏1张对方灵摆区的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理：根据选定区域（1=魔陷区，2=灵摆区）选择并破坏对方1张卡，若满足附加条件则执行后续盖放/放置处理。
function c14756848.desop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方主要魔法与陷阱区域选择1张卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,c14756848.desfilter1,tp,0,LOCATION_SZONE,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end
		-- 手动显示被选为对象的卡的动画，并记录这些卡为对象。
		Duel.HintSelection(g)
		-- 破坏对象卡；若破坏成功且自己魔陷区有空位，则继续判断能否盖放。
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK)
			and tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable()
			-- 询问玩家是否把破坏的那张魔法·陷阱卡在自己场上盖放。
			and Duel.SelectYesNo(tp,aux.Stringid(14756848,3)) then  --"把破坏的那张魔法·陷阱卡在自己场上盖放？"
			-- 中断当前效果处理，使后续的盖放处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将破坏的那张魔法·陷阱卡盖放到自己场上。
			Duel.SSet(tp,tc)
		end
	else
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方灵摆区域选择1张卡作为破坏对象。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_PZONE):Select(tp,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end
		-- 手动显示被选为对象的卡的动画，并记录这些卡为对象。
		Duel.HintSelection(g)
		-- 破坏对象卡；若破坏成功，继续判断能否放置到灵摆区域。
		if Duel.Destroy(g,REASON_EFFECT)~=0
			-- 检查自己的灵摆区域是否至少有一个空位（左/右）。
			and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK) and not tc:IsForbidden()
			-- 询问玩家是否把破坏的那张卡在自己的灵摆区域放置。
			and Duel.SelectYesNo(tp,aux.Stringid(14756848,4)) then  --"把破坏的那张卡在自己的灵摆区域放置？"
			-- 中断当前效果处理，使后续的放置处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将破坏的那张卡在自己的灵摆区域表侧放置。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

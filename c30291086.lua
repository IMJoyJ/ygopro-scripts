--メンタル・チューナー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●把光·暗属性怪兽各最多1只从自己的手卡·墓地除外才能发动。直到回合结束时这张卡的等级上升或者下降除外数量的数值。
-- ●以除外的自己的光·暗属性怪兽各最多1只为对象才能发动。那些怪兽回到墓地，直到回合结束时这张卡的等级上升或者下降回去数量的数值。
local s,id,o=GetID()
-- 注册“精神调整员”的起动效果：设置其只在怪兽区可发动、1回合1次，并指定发动时的目标/效果选择处理函数 s.lvtg，从而实现对两个分支效果的选择发动。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	c:RegisterEffect(e1)
end
-- 定义代价过滤器：选择自己手卡·墓地中属性为光或暗、且可以作为代价除外的怪兽。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsAbleToRemoveAsCost()
end
-- 定义对象过滤器：选择除外区中表侧表示、属性为光或暗、且可以送去墓地的自己怪兽。
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsFaceup() and c:IsAbleToGrave()
end
-- 发动时的目标处理：检测两个分支是否可行；可行时弹出选项让玩家选择“除外手卡·墓地的怪兽”或“回收除外的怪兽”；选择前者则无对象，从手卡·墓地选1~2只属性互不相同的光·暗怪兽除外作为代价并设置操作 s.lvop1；选择后者则取对象，从除外区选1~2只属性互不相同的光·暗怪兽作为对象并设置操作 s.lvop2，同时登记送墓操作信息。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查自己手卡·墓地是否存在至少1只可作为代价除外的光·暗属性怪兽，用于判断“除外手卡·墓地的怪兽”分支是否可用。
	local b1=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	-- 检查自己除外区是否存在至少1只表侧表示的光·暗属性怪兽可作为对象送去墓地，用于判断“回收除外的怪兽”分支是否可用。
	local b2=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支都可用时，弹出选项菜单让玩家选择：选项0为“除外手卡·墓地的怪兽”，选项1为“回收除外的怪兽”，选择结果存入 op。
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))  --"除外手卡·墓地的怪兽/回收除外的怪兽"
	elseif b1 then
		-- 只有除外分支可用时，直接选择“除外手卡·墓地的怪兽”（op=0）。
		op=Duel.SelectOption(tp,aux.Stringid(id,0))  --"除外手卡·墓地的怪兽"
	else
		-- 只有回收分支可用时，选择“回收除外的怪兽”，并加1使分支编号与双选项情形一致（op=1）。
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"回收除外的怪兽"
	end
	if op==0 then
		e:SetProperty(0)
		e:SetCategory(0)
		-- 获取自己手卡·墓地中所有满足代价过滤条件的光·暗属性怪兽集合，作为可选代价候选。
		local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
		-- 显示“请选择要除外的卡”的选择提示，供玩家选择代价卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从候选组中让玩家选择1~2只怪兽，且所选怪兽属性互不相同（保证光·暗属性各最多1只），返回所选择的组 sg。
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,2)
		-- 将选择的怪兽以表侧表示除外，作为发动效果的代价。
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
		e:SetLabel(#sg)
		e:SetOperation(s.lvop1)
	else
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 获取自己除外区中所有满足对象过滤条件（表侧表示、光·暗属性、可送墓）的怪兽集合，作为可选对象候选。
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil)
		-- 显示“请选择要送去墓地的卡”的选择提示，供玩家选择对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从候选组中让玩家选择1~2只怪兽，且所选怪兽属性互不相同（保证光·暗属性各最多1只），作为本效果的对象。
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,2)
		-- 将选择的怪兽设置为当前连锁的处理对象（取对象）。
		Duel.SetTargetCard(sg)
		e:SetOperation(s.lvop2)
		-- 设置操作信息：声明本次效果涉及“送去墓地”分类，对象候选为 g，数量为1，用于其他卡片的连锁响应检测。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
-- 处理“除外手卡·墓地的怪兽”的效果：确认此卡仍表侧且与效果相关，读取除外数量 lv；若当前等级不高于 lv 则只能选择上升，否则可选择上升或下降；随后赋予此卡一个持续到回合结束的等级变更效果，按选择增加或减少 lv。
function s.lvop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local lv=e:GetLabel()
	local op=0
	if c:IsLevelBelow(lv) then
		-- 当此卡当前等级不高于 lv 时，只显示“等级上升”选项（op=0）。
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"等级上升"
	else
		-- 当此卡等级高于 lv 时，弹出“等级上升/等级下降”选项，让玩家选择（op=0上升，op=1下降）。
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"等级上升/等级下降"
	end
	-- 直到回合结束时这张卡的等级上升或者下降除外数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	if op==0 then
		e1:SetValue(lv)
	else
		e1:SetValue(-lv)
	end
	c:RegisterEffect(e1)
end
-- 处理“回收除外的怪兽”的效果：取得本连锁的对象，将其全部送去墓地；若成功且此卡仍表侧相关，则统计实际送入墓地的数量 lv；根据此卡等级与 lv 的关系让玩家选择上升或下降，最后赋予此卡持续到回合结束的等级变更效果。
function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与本效果关联的连锁对象组（即发动时选择的除外区怪兽）。
	local g=Duel.GetTargetsRelateToChain()
	-- 若存在关联对象，则将这些对象送去墓地（原因为效果并附加回到墓地），并判断是否至少1张成功，成功才继续处理。
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)>0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 从上次卡片操作实际处理的卡片中，统计当前位于墓地的卡的数量，作为等级上升/下降的数值 lv。
		local lv=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		local op=0
		if c:IsLevelBelow(lv) then
			-- 当此卡当前等级不高于 lv 时，只显示“等级上升”选项（op=0）。
			op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"等级上升"
		else
			-- 当此卡等级高于 lv 时，弹出“等级上升/等级下降”选项，让玩家选择（op=0上升，op=1下降）。
			op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"等级上升/等级下降"
		end
		-- 那些怪兽回到墓地，直到回合结束时这张卡的等级上升或者下降回去数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		if op==0 then
			e1:SetValue(lv)
		else
			e1:SetValue(-lv)
		end
		c:RegisterEffect(e1)
	end
end

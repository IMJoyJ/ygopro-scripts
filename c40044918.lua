--E・HERO エアーマン
-- 效果：
-- ①：这张卡召唤·特殊召唤时，可以从以下效果选择1个发动。
-- ●把最多有自己场上的其他的「英雄」怪兽数量的场上的魔法·陷阱卡破坏。
-- ●从卡组把1只「英雄」怪兽加入手卡。
function c40044918.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤时，可以从以下效果选择1个发动。●把最多有自己场上的其他的「英雄」怪兽数量的场上的魔法·陷阱卡破坏。●从卡组把1只「英雄」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40044918,0))  --"选择一个效果发动"
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40044918.tg)
	e1:SetOperation(c40044918.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：筛选表侧表示且字段为「英雄」的怪兽，用于统计自己场上其他「英雄」怪兽的数量（调用时以自身作为排除项）。
function c40044918.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 定义过滤函数：筛选卡组中字段为「英雄」、属于怪兽且能被加入手卡的卡，作为检索候选。
function c40044918.schfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义过滤函数：筛选场上的魔法·陷阱卡，作为破坏候选。
function c40044918.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的判定与选择函数：检查是否存在可发动的破坏魔陷或检索英雄选项；若存在则让玩家选择要发动的分支，并设置对应效果分类和操作信息。
function c40044918.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 统计自己场上除自身外的其他表侧「英雄」怪兽数量，作为破坏魔法·陷阱卡的数量上限。
		local ct=Duel.GetMatchingGroupCount(c40044918.ctfilter,tp,LOCATION_MZONE,0,c)
		local sel=0
		-- 若自己场上有其他「英雄」怪兽且场上存在可破坏的魔法·陷阱卡，则将可选项记为包含破坏分支。
		if ct>0 and Duel.IsExistingMatchingCard(c40044918.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then sel=sel+1 end
		-- 若卡组中存在可加入手卡的「英雄」怪兽，则将可选项记为包含检索分支。
		if Duel.IsExistingMatchingCard(c40044918.schfilter,tp,LOCATION_DECK,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		-- 向玩家提示选择效果的说明文字“选择一个效果发动”。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40044918,0))  --"选择一个效果发动"
		-- 当破坏与检索分支均可选择时，用选项菜单让玩家选择；返回值+1作为分支编号（1为破坏，2为检索）。
		sel=Duel.SelectOption(tp,aux.Stringid(40044918,1),aux.Stringid(40044918,2))+1  --"魔法·陷阱卡破坏/「英雄」怪兽加入手卡"
	elseif sel==1 then
		-- 当只有破坏分支可选时，显示“魔法·陷阱卡破坏”选项（返回值不参与分支选择），分支确定为破坏。
		Duel.SelectOption(tp,aux.Stringid(40044918,1))  --"魔法·陷阱卡破坏"
	else
		-- 当只有检索分支可选时，显示“「英雄」怪兽加入手卡”选项（返回值不参与分支选择），分支确定为检索。
		Duel.SelectOption(tp,aux.Stringid(40044918,2))  --"「英雄」怪兽加入手卡"
	end
	e:SetLabel(sel)
	if sel==1 then
		-- 获取场上所有魔法·陷阱卡，作为破坏分支的候选对象集合。
		local g=Duel.GetMatchingGroup(c40044918.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		e:SetCategory(CATEGORY_DESTROY)
		-- 登记破坏效果的操作信息：目标范围为场上全部魔法·陷阱卡，预定处理数量为1（实际选择数在效果处理时按上限决定），用于星尘龙等效果响应。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 登记检索效果的操作信息：从自己卡组将1张卡加入手卡（具体卡在效果处理时选择），用于连锁响应判定。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理函数：根据发动时选择的分支执行——破坏分支中选择场上最多为其他「英雄」怪兽数量的魔法·陷阱卡破坏；检索分支中从卡组选1只「英雄」怪兽加入手卡并向对方确认。
function c40044918.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 再次统计自己场上其他表侧「英雄」怪兽数量，用于确定本次破坏分支可处理的数量上限。
		local ct=Duel.GetMatchingGroupCount(c40044918.ctfilter,tp,LOCATION_MZONE,0,c)
		-- 再次获取场上所有魔法·陷阱卡，作为本次破坏分支的候选对象。
		local g=Duel.GetMatchingGroup(c40044918.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if ct>0 and g:GetCount()>0 then
			-- 向玩家显示“请选择要破坏的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g:Select(tp,1,ct,nil)
			-- 为手动选中的破坏对象播放被选中的动画，并记录这些卡为本次效果的对象。
			Duel.HintSelection(dg)
			-- 以效果原因将选中的魔法·陷阱卡破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	else
		-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1只字段为「英雄」、属于怪兽且能被加入手卡的卡。
		local g=Duel.SelectMatchingCard(tp,c40044918.schfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示本次加入手卡的卡，完成确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

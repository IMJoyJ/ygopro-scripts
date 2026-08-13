--世壊同心
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从自己墓地把1只攻击力1500/守备力2100的怪兽特殊召唤。
-- ●自己的场上（表侧表示）·墓地·除外状态的1只「维萨斯-斯塔弗罗斯特」和4只攻击力1500/守备力2100的怪兽回到卡组，把1只「维萨斯」同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始化函数，将卡号56099748登记为记载卡名，并创建·注册该卡片的魔法卡发动效果（1回合1次，可在自由时点发动）。
function s.initial_effect(c)
	-- 将卡号56099748（「维萨斯-斯塔弗罗斯特」）登记为这张卡的记载卡名，用于后续效果文本中记载卡名的相关判定。
	aux.AddCodeList(c,56099748)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从自己墓地把1只攻击力1500/守备力2100的怪兽特殊召唤。●自己的场上（表侧表示）·墓地·除外状态的1只「维萨斯-斯塔弗罗斯特」和4只攻击力1500/守备力2100的怪兽回到卡组，把1只「维萨斯」同调怪兽当作同调召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤候选的过滤条件：从墓地选择1只攻击力1500、守备力2100且可被效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义返回卡组候选的第1种过滤条件：卡名为「维萨斯-斯塔弗罗斯特」（卡号56099748）。
function s.tdfilter1(c)
	return c:IsCode(56099748)
end
-- 定义返回卡组候选的第2种过滤条件：攻击力1500且守备力2100的怪兽。
function s.tdfilter2(c)
	return c:IsAttack(1500) and c:IsDefense(2100)
end
-- 检查5张返回卡组的组合是否符合效果要求：包含1只「维萨斯-斯塔弗罗斯特」和4只攻击力1500/守备力2100的怪兽，并且额外卡组存在可当作同调召唤特殊召唤的「维萨斯」同调怪兽。
function s.tdcheck(g,e,tp)
	-- 若额外卡组不存在满足条件的「维萨斯」同调怪兽可被特殊召唤，则直接判定该组合不合法。
	if not Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) then return false end
	local g1=g:Filter(s.tdfilter1,nil)
	if #g1==1 and g:FilterCount(s.tdfilter2,g1)==4 then return true end
	return g:CheckSubGroupEach({s.tdfilter1,s.tdfilter2,s.tdfilter2,s.tdfilter2,s.tdfilter2})
end
-- 设置额外子组检查条件：在从候选卡组选择5张卡时，每一步的子组必须包含「维萨斯-斯塔弗罗斯特」（若子组只有1张的情况除外，但实际选择5张时强制包含），以保证最终组合满足1+4。
function s.gcheck(g)
	return #g==1 or g:IsExists(s.tdfilter1,1,nil)
end
-- 定义同调特殊召唤候选的过滤条件：额外卡组的「维萨斯」同调怪兽（字段0x198），且能被当作同调召唤特殊召唤；若指定了返回卡组的卡组g，还需保证返回后额外区域有空位。
function s.synfilter(c,e,tp,g)
	return c:IsSetCard(0x198) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 当存在返回卡组的候选组g时，判定将g放回卡组后己方额外怪兽区域仍有空格可特殊召唤该同调怪兽。
		and (g==nil or Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
end
-- 定义返回卡组候选的合并过滤条件：属于「维萨斯-斯塔弗罗斯特」或攻击力1500/守备力2100的怪兽，且处于场上表侧表示·墓地·除外状态，并且能够返回卡组。
function s.tdfilter(c)
	return (s.tdfilter1(c) or s.tdfilter2(c)) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 效果发动时的条件判定与分支选择：检测两个分支（墓地特召/回收后同调特召）是否分别可行，让玩家选择要发动的分支，并设置对应的效果分类与操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否存在空位，用于分支一从墓地特殊召唤怪兽。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足特殊召唤条件的攻击力1500/守备力2100的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 and b1 then return true end
	-- 取得己方场上（表侧表示）·墓地·除外状态中所有可作为返回卡组材料的候选卡（「维萨斯-斯塔弗罗斯特」或攻击力1500/守备力2100的怪兽）。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	-- 为后续CheckSubGroup检查额外设置子组限制：组合必须包含「维萨斯-斯塔弗罗斯特」。
	aux.GCheckAdditional=s.gcheck
	-- 检查额外卡组是否存在至少1只可当作同调召唤特殊召唤的「维萨斯」同调怪兽，作为分支二的前提。
	local b2=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
		and g:CheckSubGroup(s.tdcheck,5,5,e,tp)
	-- 清除额外子组检查限制，避免影响之后其他选择操作。
	aux.GCheckAdditional=nil
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支都可用时，让玩家选择：选项0为『从墓地特殊召唤』，选项1为『回收并同调召唤』，返回选择序号存入op。
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))  --"从墓地特殊召唤/回收并同调召唤"
	elseif b1 then
		-- 仅分支一可用时，让玩家选择唯一的『从墓地特殊召唤』选项。
		op=Duel.SelectOption(tp,aux.Stringid(id,0))  --"从墓地特殊召唤"
	else
		-- 仅分支二可用时，让玩家选择唯一的『回收并同调召唤』选项，并将序号+1使op=1以便后续统一区分。
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"回收并同调召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 登记操作信息：本效果处理将包含从墓地特殊召唤1只怪兽（分类为特殊召唤）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
		-- 登记操作信息：本效果处理将包含从额外卡组特殊召唤1只怪兽（分类为特殊召唤）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 登记操作信息：本效果处理将包含从场上·墓地·除外状态把5张卡返回卡组（分类为回卡组）。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 效果处理函数：根据发动时选择的op执行对应分支——op=0时从墓地选择1只符合条件的怪兽特殊召唤；op=1时先选择5张卡返回卡组并洗牌，再从额外卡组选择1只「维萨斯」同调怪兽当作同调召唤特殊召唤，并完成同调程序。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要特殊召唤的卡（墓地特召分支）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从己方墓地选择1只攻击力1500/守备力2100且可特殊召唤的怪兽（过滤条件中已排除受『王家长眠之谷』影响的卡）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上（无特殊召唤类型，即通常的效果特殊召唤）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 取得己方场上（表侧表示）·墓地·除外状态中所有可作为返回卡组材料的候选卡（已用王家长眠之谷过滤器排除受影响卡）。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:SelectSubGroup(tp,s.tdcheck,false,5,5,e,tp)
		if sg then
			-- 为选中的返回卡组卡片显示选中动画，并将其记录为与当前效果关联的对象。
			Duel.HintSelection(sg)
			-- 将选中的5张卡返回持有者卡组并洗牌；若实际返回数量不为0则继续执行同调特殊召唤。
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
				-- 提示玩家选择要特殊召唤的卡（同调召唤分支）。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 玩家从额外卡组选择1只满足条件的「维萨斯」同调怪兽。
				local tg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
				local tc=tg:GetFirst()
				if tc then
					-- 将选择的「维萨斯」同调怪兽以表侧攻击表示特殊召唤，召唤类型为同调召唤（SUMMON_TYPE_SYNCHRO），即视为同调召唤处理。
					Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
		end
	end
end

--世壊同心
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从自己墓地把1只攻击力1500/守备力2100的怪兽特殊召唤。
-- ●自己的场上（表侧表示）·墓地·除外状态的1只「维萨斯-斯塔弗罗斯特」和4只攻击力1500/守备力2100的怪兽回到卡组，把1只「维萨斯」同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：登记关联卡名「维萨斯-斯塔弗罗斯特」，并注册1回合只能发动1张的魔法卡发动效果
function s.initial_effect(c)
	-- 记录该卡效果文上记载了「维萨斯-斯塔弗罗斯特」的卡名
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
-- 过滤条件函数：筛选墓地中攻击力1500/守备力2100且可被通常特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件函数：筛选卡名为「维萨斯-斯塔弗罗斯特」的卡
function s.tdfilter1(c)
	return c:IsCode(56099748)
end
-- 过滤条件函数：筛选攻击力1500/守备力2100的怪兽
function s.tdfilter2(c)
	return c:IsAttack(1500) and c:IsDefense(2100)
end
-- 子集校验函数：检查所选5张卡返回卡组后额外卡组仍有可同调召唤的「维萨斯」怪兽，且这5张卡恰好能拆分为1只「维萨斯-斯塔弗罗斯特」与4只攻1500/守2100的怪兽
function s.tdcheck(g,e,tp)
	-- 检查当这组卡离场回到卡组后，额外卡组是否存在可用空位来特殊召唤「维萨斯」同调怪兽
	if not Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) then return false end
	local g1=g:Filter(s.tdfilter1,nil)
	if #g1==1 and g:FilterCount(s.tdfilter2,g1)==4 then return true end
	return g:CheckSubGroupEach({s.tdfilter1,s.tdfilter2,s.tdfilter2,s.tdfilter2,s.tdfilter2})
end
-- 子集搜索剪枝函数：确保选取多个卡的组合时至少包含1只「维萨斯-斯塔弗罗斯特」
function s.gcheck(g)
	return #g==1 or g:IsExists(s.tdfilter1,1,nil)
end
-- 过滤条件函数：筛选额外卡组中可当作同调召唤特殊召唤的「维萨斯」怪兽，并在指定离场卡组时校验额外怪兽区空位
function s.synfilter(c,e,tp,g)
	return c:IsSetCard(0x198) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 当未传入回卡组卡片组时跳过空格检查，否则确认那些卡离场后场上是否有空位供该同调怪兽出场
		and (g==nil or Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
end
-- 过滤条件函数：筛选「维萨斯-斯塔弗罗斯特」或攻1500/守2100的怪兽，且为表侧表示（场上）或非里侧除外并能够返回卡组
function s.tdfilter(c)
	return (s.tdfilter1(c) or s.tdfilter2(c)) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 效果发动检查与选项选择函数：分别判断两个分支效果的可发动性，让玩家选择要发动的效果分支并设置对应的Category与操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在空位，作为第1个分支效果的条件之一
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只攻击力1500/守备力2100且可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 and b1 then return true end
	-- 获取自己场上（表侧表示）·墓地·除外状态中所有符合回收条件的候补卡片组
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	-- 设置子集组合检查时的附加剪枝函数，以优化筛选5张回收卡的性能
	aux.GCheckAdditional=s.gcheck
	-- 检查玩家是否不受“必须使用指定怪兽作为同调素材”的限制影响
	local b2=aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查自己额外卡组是否存在可当作同调召唤特殊召唤的「维萨斯」同调怪兽
		and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
		and g:CheckSubGroup(s.tdcheck,5,5,e,tp)
	-- 清除子集组合检查的附加剪枝函数，恢复默认状态
	aux.GCheckAdditional=nil
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个效果分支均可发动时，让玩家在两个选项中选择1个发动
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))  --"从墓地特殊召唤/回收并同调召唤"
	elseif b1 then
		-- 当仅第1个效果分支可发动时，向玩家提示并选定第1个分支
		op=Duel.SelectOption(tp,aux.Stringid(id,0))  --"从墓地特殊召唤"
	else
		-- 当仅第2个效果分支可发动时，向玩家提示并选定第2个分支（选项索引加1以区分第1分支）
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"回收并同调召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 向系统登记操作信息：将会从自己墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
		-- 向系统登记操作信息：将会从自己额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 向系统登记操作信息：将会使自己场上·墓地·除外状态的5张卡返回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 效果处理函数：根据发动时所选分支，从墓地特殊召唤1只攻1500/守2100的怪兽，或将5只指定怪兽回卡组洗切后从额外卡组同调召唤1只「维萨斯」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 向玩家发送选择提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1只不受王家长眠之谷限制的攻击力1500/守备力2100的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的墓地怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 效果处理时再次确认玩家不受“必须作为同调素材”的限制，若受限则中止处理
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
		-- 获取自己场上·墓地·除外状态中所有不受王家长眠之谷限制且符合回收条件的候补卡片组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 向玩家发送选择提示：请选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:SelectSubGroup(tp,s.tdcheck,false,5,5,e,tp)
		if sg then
			-- 向双方玩家展示所选将要返回卡组的5只怪兽
			Duel.HintSelection(sg)
			-- 将选择的5只怪兽作为效果返回持有者卡组并洗牌，若成功返回至少1张则继续后续处理
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
				-- 向玩家发送选择提示：请选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让玩家从自己额外卡组选择1只符合条件的「维萨斯」同调怪兽
				local tg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
				local tc=tg:GetFirst()
				if tc then
					-- 将选择的「维萨斯」同调怪兽以表侧表示当作同调召唤特殊召唤到自己场上
					Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
		end
	end
end

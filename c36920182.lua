--世壊同心
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从自己墓地把1只攻击力1500/守备力2100的怪兽特殊召唤。
-- ●自己的场上（表侧表示）·墓地·除外状态的1只「维萨斯-斯塔弗罗斯特」和4只攻击力1500/守备力2100的怪兽回到卡组，把1只「维萨斯」同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果，注册卡名和发动条件
function s.initial_effect(c)
	-- 记录该卡拥有「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足攻击力1500/守备力2100的怪兽，且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡号为56099748的怪兽（维萨斯-斯塔弗罗斯特）
function s.tdfilter1(c)
	return c:IsCode(56099748)
end
-- 过滤攻击力1500/守备力2100的怪兽
function s.tdfilter2(c)
	return c:IsAttack(1500) and c:IsDefense(2100)
end
-- 检查是否满足回收并同调召唤的条件
function s.tdcheck(g,e,tp)
	-- 检查额外卡组是否存在满足条件的同调怪兽
	if not Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) then return false end
	local g1=g:Filter(s.tdfilter1,nil)
	if #g1==1 and g:FilterCount(s.tdfilter2,g1)==4 then return true end
	return g:CheckSubGroupEach({s.tdfilter1,s.tdfilter2,s.tdfilter2,s.tdfilter2,s.tdfilter2})
end
-- 检查所选卡组是否包含至少一个维萨斯-斯塔弗罗斯特或总共一张
function s.gcheck(g)
	return #g==1 or g:IsExists(s.tdfilter1,1,nil)
end
-- 过滤满足同调召唤条件的「维萨斯」怪兽
function s.synfilter(c,e,tp,g)
	return c:IsSetCard(0x198) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查是否满足额外召唤区域的召唤条件
		and (g==nil or Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
end
-- 过滤可返回卡组的怪兽（维萨斯-斯塔弗罗斯特或攻击力1500/守备力2100）
function s.tdfilter(c)
	return (s.tdfilter1(c) or s.tdfilter2(c)) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 设置效果发动时的选择逻辑，判断是否可发动两种效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 and b1 then return true end
	-- 获取场上/墓地/除外区所有可返回卡组的怪兽
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	-- 设置额外检查条件，用于判断是否满足回收条件
	aux.GCheckAdditional=s.gcheck
	-- 检查额外卡组是否存在满足条件的同调怪兽
	local b2=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
		and g:CheckSubGroup(s.tdcheck,5,5,e,tp)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择发动效果1（从墓地特殊召唤）或效果2（回收并同调召唤）
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))  --"从墓地特殊召唤/回收并同调召唤"
	elseif b1 then
		-- 选择发动效果1（从墓地特殊召唤）
		op=Duel.SelectOption(tp,aux.Stringid(id,0))  --"从墓地特殊召唤"
	else
		-- 选择发动效果2（回收并同调召唤）
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"回收并同调召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：从墓地特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
		-- 设置操作信息：从额外卡组特殊召唤同调怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置操作信息：将5张卡返回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 执行效果发动时的处理逻辑
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的墓地怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 获取所有可返回卡组的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:SelectSubGroup(tp,s.tdcheck,false,5,5,e,tp)
		if sg then
			-- 显示选中的卡被选为对象的动画
			Duel.HintSelection(sg)
			-- 将选中的卡返回卡组
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 选择满足条件的同调怪兽
				local tg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
				local tc=tg:GetFirst()
				if tc then
					-- 将选中的同调怪兽特殊召唤
					Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
		end
	end
end

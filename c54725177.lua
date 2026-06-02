--銀河眼の輝光子竜
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把包含自己场上的怪兽的自己·对方场上2只攻击力2000以上的表侧表示怪兽解放从手卡特殊召唤。
-- ②：自己·对方的主要阶段，把场上的这张卡除外才能发动。从自己的卡组·墓地把1只「银河眼光子龙」特殊召唤。那之后，可以把从额外卡组特殊召唤的对方场上1只怪兽直到结束阶段除外。
local s,id,o=GetID()
-- 注册卡片的效果：①手牌规则特殊召唤效果（一回合一次，需解放自己及对方场上共2只攻击力2000以上的表侧表示怪兽），②二速起动效果（主要阶段把自身除外，从卡组·墓地特殊召唤「银河眼光子龙」，并可选将对方场上额外特召的怪兽直到结束阶段暂时除外）。
function s.initial_effect(c)
	-- 在当前卡片的数据中，注册其效果文本中记载了「银河眼光子龙」（93717133）的事实。
	aux.AddCodeList(c,93717133)
	-- ①：这张卡可以把包含自己场上的怪兽的自己·对方场上2只攻击力2000以上的表侧表示怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把场上的这张卡除外才能发动。从自己的卡组·墓地把1只「银河眼光子龙」特殊召唤。那之后，可以把从额外卡组特殊召唤的对方场上1只怪兽直到结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义规则特召解放怪兽过滤函数：过滤出在场上表侧表示、攻击力在2000以上，且在特召规则上可以被解放的怪兽卡片。
function s.rfilter(c,tp)
	return c:IsFaceup() and c:IsAttackAbove(2000)
		and c:IsReleasable(REASON_SPSUMMON)
end
-- 定义规则特召解放组合限制函数：判断选取的怪兽组中，必须至少有一只属于当前玩家控制（自己场上），并且解放这些怪兽后主怪兽区域仍有空格。
function s.fselect(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp)
		-- 确认选中的怪兽组离开场上后，主要怪兽区域是否有可用的空置格子。
		and Duel.GetMZoneCount(tp,g)>0
end
-- 手牌特殊召唤的条件检查函数：如果卡片不存在则返回成功，否则确认双方场上是否存在符合解放条件的攻击力2000以上的怪兽，并且存在至少一组满足组合条件的搭配。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索双方场上符合特召解放条件的攻击力2000以上表侧表示怪兽组。
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	return rg:CheckSubGroup(s.fselect,2,2,tp)
end
-- 手牌特殊召唤的区域选择函数：在场上检索符合条件的怪兽，提示玩家并选择2只攻击力2000以上的怪兽解放，同时将选中的怪兽组保存在当前效果的标签中。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索双方场上符合特召解放条件的攻击力2000以上表侧表示怪兽组。
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 向玩家发送选择提示信息：请选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的实际处理函数：从当前效果的标签中获取被选中的怪兽组，将它们全部进行解放以完成特殊召唤。
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤原因解放选中的怪兽卡组。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 二速特召效果的发动条件检查：确认当前是否处于自己或者对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于主要阶段。
	return Duel.IsMainPhase()
end
-- 二速特召效果的发动代价处理函数：确认场上的当前卡片自身可以被除外，并将自身表侧表示除外作为效果发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 以发动效果代价原因为由，将场上的当前卡片自身进行除外处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义特召怪兽过滤函数：过滤出属于「银河眼光子龙」（93717133）且可以被正常特殊召唤的卡片。
function s.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 二速特召效果的发动检测与准备：确认本卡作为代价除外离场后主怪兽区域有空位，且卡组或墓地中存在符合条件的「银河眼光子龙」，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查若当前卡片离开场上，主要怪兽区域是否还有可用的空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组和墓地中是否至少存在1张符合特殊召唤过滤条件的「银河眼光子龙」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：包含特殊召唤怪兽的分类，数量为1，目标区域为卡组和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义除外怪兽过滤函数：过滤出对方场上可以被除外、且是从额外卡组中特殊召唤上场的怪兽卡片。
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 二速特召效果的实际处理过程：检查格子空位后，提示玩家从卡组或墓地选择1只「银河眼光子龙」特殊召唤；若特召成功，且对方场上存在从额外卡组特召的怪兽，玩家可以选择将对方1只额外特召怪兽直到结束阶段暂时除外，并注册回合结束阶段将其返回场上的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己主要怪兽区域可用的空格数大于等于1，否则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示信息：请选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组和墓地中选择1张不受王家长眠之谷影响的、符合特殊召唤条件的「银河眼光子龙」卡片。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的「银河眼光子龙」特殊召唤到自己场上，并判断特殊召唤是否成功。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查对方场上是否存在符合除外过滤条件的额外特召怪兽。
		if Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 向玩家提问：是否要把怪兽除外？
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽除外？"
			-- 中断当前的效果处理，使得特殊召唤与后续的除外处理不视为同时进行（会使时点错开）。
			Duel.BreakEffect()
			-- 向玩家发送选择提示信息：请选择要除外的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 让玩家选择对方场上的1只符合除外条件的额外特召怪兽卡片。
			local tg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
			local rc=tg:GetFirst()
			-- 手动为被选中的怪兽显示选择动画效果，并记录其为当前效果的处理对象。
			Duel.HintSelection(tg)
			-- 以效果原因和暂时除外为由，将对方的该怪兽除外，并确认是否成功除外。
			if Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"直到结束阶段除外"
				-- 直到结束阶段除外
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(rc)
				e1:SetCountLimit(1)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				-- 注册一个将在回合结束阶段触发的全局效果，用于将被除外的怪兽返回场上。
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 返回场上效果的触发条件检查：确保目标的怪兽卡片上仍带有所注册的标识。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 返回场上效果的实际处理函数：将被除外的怪兽重新返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽卡片以其离场前的表示形式返回到原来的场上区域。
	Duel.ReturnToField(e:GetLabelObject())
end

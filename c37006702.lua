--クリシュナード・ウィッチ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：场地区域的卡因效果从场上离开的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要场上有「多元宇宙」存在，这张卡不会被对方的效果破坏。
-- ③：已是表侧表示存在的场地魔法卡的效果发动时才能发动。自己的墓地·除外状态的1只怪兽回到卡组。那只怪兽有那张发动的场地魔法卡的卡名记述的场合，可以不回到卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：为这张卡登记「多元宇宙」的关联卡名，并依次注册②的永续抗性效果、①的手卡特召诱发效果、③的墓地·除外怪兽回卡组/特召的诱发即时效果。
function s.initial_effect(c)
	-- 将卡号885016（多元宇宙）加入这张卡的效果文本记载卡名列表，使后续可用aux.IsCodeListed判断墓地·除外怪兽是否记载了该场地魔法卡的卡名。
	aux.AddCodeList(c,885016)
	-- ②：只要场上有「多元宇宙」存在，这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	-- 设置②抗性效果的判定值使用aux.indoval：仅当破坏效果来自对方的卡（效果发动玩家不是这张卡控制者）时，本次破坏被无效，从而实现“不会被对方的效果破坏”。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ①：场地区域的卡因效果从场上离开的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：已是表侧表示存在的场地魔法卡的效果发动时才能发动。自己的墓地·除外状态的1只怪兽回到卡组。那只怪兽有那张发动的场地魔法卡的卡名记述的场合，可以不回到卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- ②的判定过滤器：判断场上是否存在表侧表示且卡号为885016的「多元宇宙」。
function s.indfilter(c)
	return c:IsFaceup() and c:IsCode(885016)
end
-- ②的适用条件：以这张卡控制者视角检查双方场上是否存在表侧表示的「多元宇宙」，存在时②的破坏抗性生效。
function s.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查双方场上区域是否存在至少1张表侧表示的「多元宇宙」，作为②效果适用的前条件。
	return Duel.IsExistingMatchingCard(s.indfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ①的离场事件过滤器：判断事件中的卡是否因效果（REASON_EFFECT）从场地区（LOCATION_FZONE）离开。
function s.spfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
-- ①的发动条件：本次离场事件中存在因效果从场地区离开的卡，且离开的卡中不包含这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ①的发动合法检查：自己主要怪兽区有空位，且手牌中的这张卡能够被效果特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空位，作为从手卡特殊召唤的前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次连锁将把e:GetHandler()（这张卡自身）以特殊召唤方式处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡仍与该效果关联（未被无效或离场），将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果仍有关联后，将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ③的发动条件：当前连锁的效果是已经表侧表示存在于场上的场地魔法卡所发动的效果（效果的发动位置在魔陷区/场地区，效果类型包含场地，且不是场地魔法卡自身的“卡的发动”）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return bit.band(re:GetActivateLocation(),LOCATION_SZONE)~=0 and bit.band(re:GetActiveType(),TYPE_FIELD)~=0 and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ③的可选目标过滤：自己墓地的怪兽，或除外状态表侧表示的怪兽，且必须是怪兽卡。
function s.tdfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER)
end
-- ③的发动目标检查：自己墓地或除外状态表侧表示中存在可选怪兽；同时登记本次连锁可能进行的回卡组和特殊召唤操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的墓地或除外状态表侧表示的怪兽中是否存在至少1只满足条件的怪兽，作为③能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 登记操作信息：本次连锁可能将1张卡回到卡组（实际回不回卡组取决于处理时是否选择特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	-- 登记操作信息：本次连锁可能进行1次特殊召唤（若满足特召条件且玩家选择特召）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ③的效果处理：从自己墓地或除外状态表侧表示的怪兽中选1只；若场上可特召且该怪兽记载了发动效果的场地魔法卡卡名，则询问玩家是否特殊召唤；是则特召，否则将其洗回卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示框标题“请选择要返回卡组的卡”，用于后续卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地或除外状态表侧表示的怪兽中选择1张（用NecroValleyFilter过滤掉受王家长眠之谷影响而不能移动的卡），作为③要处理的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		local rc=re:GetHandler()
		-- 计算是否满足特召条件：自己主要怪兽区有空位、该怪兽能被效果特殊召唤，且该怪兽的效果文本记载了发动效果的场地魔法卡（re:GetHandler():GetCode()）的卡名。
		local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(tc,re:GetHandler():GetCode())
		-- 若满足特召条件，则询问玩家“是否特殊召唤？”；选择是则特召，选择否则执行回卡组。
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否特殊召唤？"
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 为该怪兽显示被选为对象的动画并记录其成为对象，随后将其执行回卡组处理。
			Duel.HintSelection(g)
			-- 将选中的怪兽以效果原因洗回持有者的卡组（洗切后置于卡组随机位置）。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

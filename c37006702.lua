--クリシュナード・ウィッチ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：场地区域的卡因效果从场上离开的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要场上有「多元宇宙」存在，这张卡不会被对方的效果破坏。
-- ③：已是表侧表示存在的场地魔法卡的效果发动时才能发动。自己的墓地·除外状态的1只怪兽回到卡组。那只怪兽有那张发动的场地魔法卡的卡名记述的场合，可以不回到卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果
function s.initial_effect(c)
	-- 记录该卡效果文本记载着「多元宇宙」卡名
	aux.AddCodeList(c,885016)
	-- ②：只要场上有「多元宇宙」存在，这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	-- 设置该效果为不会被对方效果破坏的过滤函数
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
-- 过滤函数：检测场上是否有表侧表示的「多元宇宙」
function s.indfilter(c)
	return c:IsFaceup() and c:IsCode(885016)
end
-- 条件函数：判断是否满足②效果的发动条件
function s.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查场上是否存在满足indfilter条件的卡
	return Duel.IsExistingMatchingCard(s.indfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤函数：检测离开场上的卡是否为场地区域的卡且因效果离开
function s.spfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
-- 条件函数：判断是否满足①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置①效果的发动时点处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果发动时的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若该卡能被特殊召唤则执行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 条件函数：判断是否满足③效果的发动条件
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return bit.band(re:GetActivateLocation(),LOCATION_SZONE)~=0 and bit.band(re:GetActiveType(),TYPE_FIELD)~=0 and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤函数：检测墓地或除外状态的怪兽
function s.tdfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER)
end
-- 设置③效果的发动时点处理目标
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可被选为对象
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置③效果发动时的回卡组处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	-- 设置③效果发动时的特殊召唤处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ③效果的发动处理
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		local rc=re:GetHandler()
		-- 判断是否满足特殊召唤的条件
		local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(tc,re:GetHandler():GetCode())
		-- 询问玩家是否选择特殊召唤
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否特殊召唤？"
			-- 执行特殊召唤操作
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 显示被选为对象的怪兽动画
			Duel.HintSelection(g)
			-- 将怪兽送回卡组
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

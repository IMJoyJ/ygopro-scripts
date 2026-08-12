--竜華襲焉
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方不能把自己场上的「龙华」怪兽作为效果的对象。
-- ②：自己的额外卡组（表侧）或场上有「龙华」灵摆怪兽存在的场合，让自己的手卡·墓地·除外状态的2只「龙华」怪兽回到卡组，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡被破坏的场合才能发动。永续陷阱卡以外的自己的卡组·墓地·除外状态的1张「龙华」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①效果（不能成为对象）、②效果（洗回怪兽破坏场上怪兽）、③效果（破坏时盖放陷阱）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能把自己场上的「龙华」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置不能成为效果对象的目标过滤条件为：字段名含有「龙华」（0x1c0）的卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1c0))
	-- 设置不能成为对方卡片的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：自己的额外卡组（表侧）或场上有「龙华」灵摆怪兽存在的场合，让自己的手卡·墓地·除外状态的2只「龙华」怪兽回到卡组，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合才能发动。永续陷阱卡以外的自己的卡组·墓地·除外状态的1张「龙华」陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上或额外卡组表侧表示的「龙华」灵摆怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM)
end
-- ②效果的发动条件：检查自己的额外卡组（表侧）或场上是否存在「龙华」灵摆怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上或额外卡组（表侧）是否存在至少1张满足条件的「龙华」灵摆怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,nil)
end
-- 过滤条件：手卡、墓地或除外状态的，可以回到卡组的「龙华」怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
-- ②效果的发动代价：将手卡·墓地·除外状态的2只「龙华」怪兽洗回卡组
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查手卡、墓地、除外状态是否存在至少2只可以洗回卡组的「龙华」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	-- 给发动玩家发送提示信息：选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡、墓地、除外状态选择2只「龙华」怪兽
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)
	local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()>0 then
		-- 如果选了手卡中的卡，向对方玩家展示这些手卡
		Duel.ConfirmCards(1-tp,hg)
	end
	-- 在场上或公开区域对选中的卡片进行闪烁提示
	Duel.HintSelection(g)
	-- 作为发动代价，将选中的卡洗回持有者卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ②效果的靶向与操作信息注册：选择场上1只怪兽作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动检测阶段，检查场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动玩家发送提示信息：选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：破坏作为对象的怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：卡组、墓地或除外状态的，非永续陷阱的「龙华」陷阱卡，且该卡可以盖放
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c0) and c:IsType(TYPE_TRAP) and not c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的靶向与操作信息注册：检查魔陷区空位及是否存在可盖放的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查卡组、墓地、除外状态是否存在至少1张满足条件的「龙华」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
-- ③效果的处理：将1张「龙华」陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己的魔法与陷阱区域没有空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 给发动玩家发送提示信息：选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组、墓地、除外状态选择1张满足条件的「龙华」陷阱卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end

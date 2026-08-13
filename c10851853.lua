--フラワーダイノ
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从除外的自己以及对方的魔法·陷阱卡之中以合计3张为对象才能发动。那些卡用喜欢的顺序回到持有者卡组下面。那之后，自己从卡组抽1张。
local s,id,o=GetID()
-- 定义并注册该卡的全部效果：e1为召唤条件限制（不能通常召唤/只能用自身效果特殊召唤），e2为①的手卡特招效果，e3为②的墓地回卡组抽卡效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的值设为false，即此卡不允许通过其他卡的效果特殊召唤，只能通过自身效果特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition1)
	e2:SetTarget(s.target1)
	e2:SetOperation(s.activate1)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，从除外的自己以及对方的魔法·陷阱卡之中以合计3张为对象才能发动。那些卡用喜欢的顺序回到持有者卡组下面。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.activate2)
	c:RegisterEffect(e3)
end
-- 触发条件：当连锁处理结束时，若对方发动了魔法卡效果或自己发动了陷阱卡效果，则满足发动条件（rp为效果发动者，re为对应效果）。
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return (rp==1-tp and re:IsActiveType(TYPE_SPELL)) or (rp==tp and re:IsActiveType(TYPE_TRAP))
end
-- 发动时判断：手卡的这张卡能否特殊召唤（需要自己主怪兽区有空位，且此卡满足特殊召唤条件）。
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的主怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 登记本次效果处理为特殊召唤这张卡的操作信息，用于连锁与时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若此卡仍在手牌且与效果关联，则将其表侧表示特殊召唤到自己场上，并执行召唤成功后的完成处理（CompleteProcedure）。
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡在效果处理时仍与效果关联，并且特殊召唤成功（返回特殊召唤数量>0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
-- ②效果选择对象的筛选条件：排除去的表侧表示的魔法·陷阱卡，且该卡能够回到卡组。
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- ②效果的发动条件与选目标：从双方除外区选择3张满足条件的魔法·陷阱卡作为对象，且自己可以抽1张卡。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查双方除外区是否存在至少3张满足筛选条件的卡（自己的除外区和对方的除外区）。
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,nil)
		-- 并且确认自己可以进行1张卡的抽卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己及对方除外区中选出3张满足条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,3,nil)
	-- 登记操作信息：将所选的卡返回卡组，分类为回卡组，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 登记操作信息：之后自己抽1张卡，抽卡玩家为tp，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：取得仍然关联的对象卡；若对象存在且成功按玩家选择顺序放回持有者卡组底，则中断效果后自己抽1张卡。
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁记录的对象中筛选出仍与此效果关联的卡片（防止对象在处理前离场导致效果失效）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果关联对象仍有剩余，且成功将对象卡放置到持有者卡组底部，则继续执行后续抽卡。
	if #tg>0 and aux.PlaceCardsOnDeckBottom(tp,tg)>0 then
		-- 中断当前效果处理流程，使回卡组与抽卡不在同一时点处理，避免错过抽卡时点。
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡，抽卡原因标记为效果。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

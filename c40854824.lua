--オーバー・ザ・レインボー
-- 效果：
-- ①：原本卡名是「究极宝玉神 虹龙」或者「究极宝玉神 虹暗龙」的怪兽在自己场上把效果发动的回合才能发动。从卡组把「宝玉兽」怪兽任意数量特殊召唤（同名卡最多1张）。
function c40854824.initial_effect(c)
	-- ①：原本卡名是「究极宝玉神 虹龙」或者「究极宝玉神 虹暗龙」的怪兽在自己场上把效果发动的回合才能发动。从卡组把「宝玉兽」怪兽任意数量特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c40854824.condition)
	e1:SetTarget(c40854824.target)
	e1:SetOperation(c40854824.activate)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器（counter_id=40854824，活动类型=ACTIVITY_CHAIN），用于记录本回合是否已经发动过原本卡名为「究极宝玉神 虹龙/虹暗龙」的怪兽效果；当chainfilter返回false时，该次效果发动会被记录。
	Duel.AddCustomActivityCounter(40854824,ACTIVITY_CHAIN,c40854824.chainfilter)
end
-- 计数器过滤函数：若发动效果是怪兽效果且其原本卡名为79407975（究极宝玉神 虹龙）或79856792（究极宝玉神 虹暗龙），则返回false使计数器加1；其余效果的发动不计数。
function c40854824.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(79407975,79856792))
end
-- 效果发动条件函数：检查玩家tp的自定义活动计数器（40854824）中ACTIVITY_CHAIN的计数是否不为0，以此判断本回合是否满足“原本卡名是究极宝玉神 虹龙或虹暗龙的怪兽在自己场上把效果发动过”的前提。
function c40854824.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp在本回合中发动符合条件的（原本卡名为虹龙/虹暗龙的）怪兽效果的次数，并判断其不为0（至少发动过一次），作为发动“飞越虹桥”的必要条件。
	return Duel.GetCustomActivityCount(40854824,tp,ACTIVITY_CHAIN)~=0
end
-- 定义“宝玉兽”怪兽的筛选条件：卡名属于0x1034（宝玉兽）系列，且能够被玩家tp以效果e特殊召唤（会检查召唤条件和苏生限制）。
function c40854824.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数：在发动时（chk==0）检查是否满足发动条件——场上存在可利用的主怪兽区，且卡组存在可特殊召唤的“宝玉兽”怪兽；此效果不取对象，无需额外选择目标。
function c40854824.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查的第一步：玩家tp的主怪兽区是否有至少1个空位；若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1张满足filter条件（宝玉兽且可特殊召唤）的卡片；与空格检查共同决定效果能否发动。
		and Duel.IsExistingMatchingCard(c40854824.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：类别为特殊召唤，目标玩家tp的卡组，count暂设为1；该信息用于系统与其他效果（如“青眼精灵龙”限制同时特殊召唤）的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：计算可用的主怪兽区空格数ft，若为0则终止；若【青眼精灵龙】的效果适用，则ft被限制为1；然后获取卡组中所有可特召的“宝玉兽”怪兽，提示玩家选择1～ft张且卡名互不相同的怪兽，最后将它们表侧表示特殊召唤到tp场上。
function c40854824.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp当前可用的主怪兽区空格数，存入变量ft，用于限制本次特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 从玩家tp的卡组中筛选出所有满足c40854824.filter（即“宝玉兽”且可被特殊召唤）的怪兽卡，组成候选集合g。
	local g=Duel.GetMatchingGroup(c40854824.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 向玩家tp显示“请选择要特殊召唤的卡”的选择提示，并将选择消息缓存供后续SelectSubGroup使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选集合g中选择1到ft张卡，且所选卡名必须各不相同（由aux.dncheck检查）；该选择不可取消，最终得到要特殊召唤的怪兽集合sg。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选中的“宝玉兽”怪兽以表侧表示特殊召唤到玩家tp的场上（sumtype=0，正常检查召唤条件和苏生限制）。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end

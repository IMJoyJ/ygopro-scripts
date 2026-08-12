--GMX研究員セラン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。把1只战士族以外的「基因组混合」怪兽或者3星以下的恐龙族怪兽从卡组特殊召唤。
-- ②：这张卡用怪兽的效果特殊召唤的场合才能发动。从卡组把1张「基因组混合」魔法·陷阱卡加入手卡。
-- ③：场上有恐龙族融合怪兽存在的场合才能发动。场上的这张卡回到卡组，场上1张表侧表示卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化这张卡的三个效果：①召唤成功时发动的从卡组特殊召唤怪兽的诱发选发效果，②用怪兽效果特殊召唤成功时发动的从卡组检索「基因组混合」魔法·陷阱卡的诱发选发效果，③场上的起动效果，各设定了1回合1次的使用次数限制
function s.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。把1只战士族以外的「基因组混合」怪兽或者3星以下的恐龙族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡用怪兽的效果特殊召唤的场合才能发动。从卡组把1张「基因组混合」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：场上有恐龙族融合怪兽存在的场合才能发动。场上的这张卡回到卡组，场上1张表侧表示卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"无效效果"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选卡组中战士族以外的「基因组混合」怪兽或者3星以下的恐龙族怪兽，且可以被特殊召唤的卡
function s.spfilter(c,e,tp)
	return (not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x1dd)
		or c:IsLevelBelow(3) and c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检测：确认自己主要怪兽区有空位，且卡组存在满足特殊召唤条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预告将从卡组特殊召唤1只怪兽，供星尘龙等效果的连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区没有空位则中断处理，否则让玩家从卡组选1只满足条件的怪兽并表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有可用空格则中断效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动条件：确认这张卡是被怪兽的效果特殊召唤的（令此卡特殊召唤的效果是怪兽效果）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数：筛选卡组中可以加入手卡的「基因组混合」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动条件检测：确认卡组存在可加入手卡的「基因组混合」魔法·陷阱卡，向对方提示发动的效果并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组存在至少1张可加入手卡的「基因组混合」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预告将从卡组把1张卡加入手卡，供连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选1张「基因组混合」魔法·陷阱卡加入手卡，并给对方确认该卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「基因组混合」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选场上表侧表示的恐龙族融合怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR)
end
-- 发动条件：确认双方场上存在恐龙族融合怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方主要怪兽区是否存在至少1只表侧表示的恐龙族融合怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 发动条件检测：确认场上存在这张卡以外可以被无效的表侧表示卡，且这张卡可以回到卡组
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认双方场上存在这张卡以外至少1张可以被无效的表侧表示卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and c:IsAbleToDeck() end
	-- 向对方玩家提示发动了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取双方场上这张卡以外所有可以被无效的表侧表示卡
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息：预告将无效场上1张卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置操作信息：预告将这张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果处理：场上的这张卡回到卡组并洗牌，成功回到卡组·额外卡组后，让玩家选场上1张表侧表示卡，无效其相关连锁，并赋予其效果无效、发动的效果无效（以及陷阱怪兽时无效其陷阱怪兽状态）的效果，直到回合结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and c:IsRelateToChain()
		-- 将场上的这张卡回到卡组并洗卡组，确认操作成功
		and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 提示玩家请选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择双方场上1张可以被无效的表侧表示卡
		local tg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if tg:GetCount()>0 then
			-- 显示所选卡被指定的动画并记录这些卡被选择
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			-- 将与所选卡相关的连锁全部无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 场上1张表侧表示卡的效果直到回合结束时无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 场上1张表侧表示卡的效果直到回合结束时无效（无效其发动的效果）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 场上1张表侧表示卡的效果直到回合结束时无效（对象是陷阱怪兽时，同时无效其陷阱怪兽状态）
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end

--GMX研究員セラン
-- 效果：
-- 这张卡召唤的场合：可以从卡组把战士族以外的1只「GMX」怪兽，或者1只3星以下的恐龙族怪兽特殊召唤。
-- 这张卡用怪兽的效果特殊召唤的场合：可以从卡组把1张「GMX」魔法·陷阱卡加入手卡。
-- 场上有恐龙族融合怪兽存在的场合：可以让场上的这张卡回到卡组，把场上1张表侧表示卡的效果直到回合结束时无效。
-- 「GMX研究员 塞兰特」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化函数，注册三个效果，分别对应卡的三种效果
function s.initial_effect(c)
	-- 第一效果：这张卡召唤的场合：可以从卡组把战士族以外的1只「GMX」怪兽，或者1只3星以下的恐龙族怪兽特殊召唤。
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
	-- 第二效果：这张卡用怪兽的效果特殊召唤的场合：可以从卡组把1张「GMX」魔法·陷阱卡加入手卡。
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
	-- 第三效果：场上有恐龙族融合怪兽存在的场合：可以让场上的这张卡回到卡组，把场上1张表侧表示卡的效果直到回合结束时无效。
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
-- 特殊召唤的过滤函数：筛选战士族以外且为GMX怪兽，或等级3以下且为恐龙族的怪兽
function s.spfilter(c,e,tp)
	return (not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x1dd)
		or c:IsLevelBelow(3) and c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的目标函数：检测是否有可用的怪兽格和满足条件的卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家怪兽区是否有可用格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示对手选择了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤的处理函数：玩家选择卡并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区没有可用格子则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择满足条件的1张卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤，将选中的卡以表侧攻击表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索效果的触发条件：必须是怪兽效果触发的特殊召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 检索的过滤函数：筛选GMX魔法或陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索的目标函数：检测卡组中是否有满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否有满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对手选择了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索的处理函数：玩家选择卡并加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认被加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检测恐龙族融合怪兽的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR)
end
-- 无效效果的触发条件函数
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否存在恐龙族融合怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 无效效果的目标函数
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测场上是否存在可以无效化的卡且自身可以回卡组
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and c:IsAbleToDeck() end
	-- 提示对手选择了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取场上所有可以无效化的卡
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置无效化操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置回卡组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 无效效果的处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and c:IsRelateToChain()
		-- 将场上的这张卡返回卡组并洗牌
		and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 提示玩家选择要无效化的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择1张要无效化的表侧表示卡
		local tg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if tg:GetCount()>0 then
			-- 显示被选为无效对象的卡的动画效果
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			-- 使与该卡相关的连锁都无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 无效化卡的效果：使怪兽不能发动效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 无效化怪兽效果：使怪兽效果被无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 无效化陷阱怪兽：如果该卡是陷阱怪兽则使其无效
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

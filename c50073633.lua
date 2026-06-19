--エルフの聖賢者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。自己手卡全部给对方观看。那之中有着有「光与暗的仪式」的卡名记述的卡的场合，自己可以抽3张。抽卡的场合，再选自己2张手卡丢弃。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
-- ②：把这张卡解放才能发动。从手卡把有「光与暗的仪式」的卡名记述的1只仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，全局启用额外卡组特殊召唤次数限制计数器，将「光与暗的仪式」的卡片密码加入关联列表，并注册①②效果
function s.initial_effect(c)
	-- 全局启用额外卡组特殊召唤次数限制计数器
	aux.EnableExtraDeckSummonCountLimit()
	-- 将「光与暗的仪式」的卡片密码加入关联列表
	aux.AddCodeList(c,33599853)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。自己手卡全部给对方观看。那之中有着有「光与暗的仪式」的卡名记述的卡的场合，自己可以抽3张。抽卡的场合，再选自己2张手卡丢弃。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放才能发动。从手卡把有「光与暗的仪式」的卡名记述的1只仪式怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤记述了「光与暗的仪式」的卡片的条件函数
function s.cfilter(c)
	-- 判断卡片是否在效果文本中记述了「光与暗的仪式」
	return aux.IsCodeListed(c,33599853)
end
-- 过滤手卡中未公开且记述了「光与暗的仪式」的卡片的条件函数
function s.cfilter2(c)
	-- 判断手卡中的卡片是否未公开且记述了「光与暗的仪式」
	return aux.IsCodeListed(c,33599853) and not c:IsPublic()
end
-- ①效果的发动目标，检查自己手卡中是否存在未公开的卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil)
		-- 并且此时手卡中没有已经公开的卡
		and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
end
-- ①效果的实际处理，展示所有手牌并判断是否进行抽卡和舍弃手卡，并设置额外卡组特殊召唤次数限制
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查手卡中是否没有已经公开的卡
	if not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) then
		-- 获取自己所有的手卡
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND,0,nil)
		local sflag=false
		if g:GetCount()>0 then
			sflag=true
			-- 将这些手卡给对方观看
			Duel.ConfirmCards(1-tp,g)
			if g:IsExists(s.cfilter2,1,nil)
				-- 检查自己是否可以抽3张卡
				and Duel.IsPlayerCanDraw(tp,3)
				-- 让玩家选择是否抽卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,2))  --"是否抽卡？"
				-- 让玩家从卡组抽3张卡
				and Duel.Draw(tp,3,REASON_EFFECT)>0 then
				-- 提示玩家选择要丢弃的手卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
				-- 从手卡选择2张可以丢弃的卡
				local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,2,2,nil,REASON_EFFECT+REASON_DISCARD)
				if dg:GetCount()>0 then
					sflag=false
					-- 洗切自己手卡
					Duel.ShuffleHand(tp)
					-- 使后续的送去墓地处理与之前的抽卡处理不视为同时进行
					Duel.BreakEffect()
					-- 将选择的卡以效果舍弃送去墓地
					Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
				end
			end
		end
		if sflag then
			-- 洗切自己手卡
			Duel.ShuffleHand(tp)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	-- 这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册用于累计特殊召唤次数的系统事件监听效果
	Duel.RegisterEffect(e2,tp)
	-- 这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册玩家从额外卡组特殊召唤次数限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 当玩家本回合从额外卡组特殊召唤的次数达到上限时，禁止其继续从额外卡组特殊召唤的限制函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 判断是否是额外卡组特殊召唤且玩家本回合特殊召唤次数限制已用尽
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 过滤玩家从额外卡组特殊召唤的怪兽的条件函数
function s.ckfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 当怪兽从额外卡组特殊召唤成功时更新对应玩家的特殊召唤剩余次数
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.ckfilter,1,nil,tp) then
		-- 将自己本回合从额外卡组特殊召唤的剩余可用次数减1
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(s.ckfilter,1,nil,1-tp) then
		-- 将对方本回合从额外卡组特殊召唤的剩余可用次数减1
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
-- ②效果的发动代价，解放自身
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否可以被解放，并且自己场上是否有空余的怪兽区域
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 解放自身
	Duel.Release(c,REASON_COST)
end
-- 过滤手卡中记述了「光与暗的仪式」的仪式怪兽的条件函数
function s.spfilter(c,e,tp)
	-- 判断怪兽是否为仪式怪兽且在效果文本中记述了「光与暗的仪式」
	return aux.IsCodeListed(c,33599853) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动目标，检查手卡中是否存在可特殊召唤的目标怪兽并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的实际处理，从手卡将1只记述了「光与暗的仪式」的仪式怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

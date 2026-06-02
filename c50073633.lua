--エルフの聖賢者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。自己手卡全部给对方观看。那之中有着有「光与暗的仪式」的卡名记述的卡的场合，自己可以抽3张。抽卡的场合，再选自己2张手卡丢弃。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
-- ②：把这张卡解放才能发动。从手卡把有「光与暗的仪式」的卡名记述的1只仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用额外卡组特殊召唤次数限制的全局计数机制，记录本卡记载着「光与暗的仪式」，注册召/特召成功时展示手牌抽卡丢牌并限制额外特召的效果（效果①），以及解放自身特召手牌中记载「光与暗的仪式」的仪式怪兽的效果（效果②）。
function s.initial_effect(c)
	-- 启用额外卡组特殊召唤次数限制的全局计数机制。
	aux.EnableExtraDeckSummonCountLimit()
	-- 记录本卡文本中记载着「光与暗的仪式」（密码为33599853）。
	aux.AddCodeList(c,33599853)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。自己手卡全部给对方观看。那之中有着有「光与暗的仪式」的卡名记述的卡的场合，自己可以抽3张。抽卡的场合，再选自己2张手卡丢弃。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡效果"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
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
-- 过滤函数：用于判断卡片的效果文本是否记载着「光与暗的仪式」。
function s.cfilter(c)
	-- 判断卡片的效果文本是否记载着「光与暗的仪式」。
	return aux.IsCodeListed(c,33599853)
end
-- 过滤函数：用于判断卡片是否记载「光与暗的仪式」且当前不为公开状态。
function s.cfilter2(c)
	-- 判断卡片是否记载着「光与暗的仪式」且当前不为公开状态。
	return aux.IsCodeListed(c,33599853) and not c:IsPublic()
end
-- 效果①的发动靶向检测函数：检查己方手牌中是否存在至少1张卡且均非公开状态。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手牌中是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil)
		-- 判断己方手牌是否全部不为公开状态。
		and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
end
-- 效果①的实际处理函数：让对方确认己方所有手牌，若有记载「光与暗的仪式」的卡，可选择抽3张并丢弃2张手牌，之后施加本回合从额外卡组只能特殊召唤1次怪兽的限制。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方手卡是否不为公开状态。
	if not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) then
		-- 获取己方所有的手牌。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND,0,nil)
		if g:GetCount()>0 then
			-- 将手牌全部向对方公开进行确认。
			Duel.ConfirmCards(1-tp,g)
			if g:IsExists(s.cfilter2,1,nil)
				-- 判断当前玩家是否可以抽3张卡。
				and Duel.IsPlayerCanDraw(tp,3)
				-- 询问玩家是否选择抽卡。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2))  --"是否抽卡？"
				-- 让玩家抽3张卡并返回实际抽卡数。
				and Duel.Draw(tp,3,REASON_EFFECT)>0 then
				-- 提示玩家选择要丢弃的手牌。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
				-- 让玩家从手牌中选择2张可丢弃的卡片。
				local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,2,2,nil,REASON_EFFECT+REASON_DISCARD)
				if dg:GetCount()>0 then
					-- 洗切手牌并重置手牌状态。
					Duel.ShuffleHand(tp)
					-- 中断当前处理，使抽卡和丢弃手牌不视为同时处理。
					Duel.BreakEffect()
					-- 将选择的2张手牌丢弃送去墓地。
					Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
				end
			end
		end
	end
	-- 在全局注册“直到回合结束限制从额外卡组特殊召唤”的玩家限制效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的限制效果。
	Duel.RegisterEffect(e1,tp)
	-- 在全局注册用于计数和扣减本回合从额外卡组特殊召唤次数的监听器效果。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册召唤次数扣减的监听器效果。
	Duel.RegisterEffect(e2,tp)
	-- 在全局注册特定召唤规则占位用的限制标记效果。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册占位限制标记效果。
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件过滤函数：若目标位置是额外卡组且当前玩家的允许特殊召唤次数小于等于0，则不能特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 判断目标位置是否为额外卡组，且该玩家的剩余额外特殊召唤次数是否已耗尽。
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 过滤函数：用于判断卡片是否是由指定玩家从额外卡组特殊召唤的。
function s.ckfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 特殊召唤监听处理函数：每当有玩家从额外卡组进行特殊召唤时，扣减其对应的特殊召唤允许次数。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.ckfilter,1,nil,tp) then
		-- 扣减当前玩家从额外卡组召唤怪兽的剩余可召唤次数。
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(s.ckfilter,1,nil,1-tp) then
		-- 扣减对方玩家从额外卡组召唤怪兽的剩余可召唤次数。
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
-- 效果②的cost检测与处理函数：检查自身是否可以解放，且解放自身后场上是否有空余的怪兽区域。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断自身是否可以解放，且解放自身后己方场上是否有可用的怪兽区域。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 解放自身。
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：用于判断手牌中是否存在记载「光与暗的仪式」且满足特殊召唤条件的仪式怪兽。
function s.spfilter(c,e,tp)
	-- 判断卡片是否为手牌中记载「光与暗的仪式」的仪式怪兽且能够被特殊召唤。
	return aux.IsCodeListed(c,33599853) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的靶向检测函数：检查手牌中是否存在可以特殊召唤的符合条件的仪式怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的实际处理函数：若场上有空位，让玩家选择手牌中1只满足条件的仪式怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择手牌中满足特殊召唤条件的仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的仪式怪兽无视召唤条件特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

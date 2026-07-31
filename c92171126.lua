--糾罪巧β’－「alazoneIA」
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：包含从卡组把卡加入手卡效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
-- ③：这张卡反转的场合发动。对方手卡随机选1张直到结束阶段表侧除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册灵摆属性、放置指示物许可、灵摆区域放置指示物、P效果检索加手、手牌里侧特召怪兽、场上里侧变表侧检索、反转时随机除外对方手牌效果
function s.initial_effect(c)
	-- 设置灵摆怪兽属性（允许放置在灵摆区域发动）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- P效果①：每次有怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- P效果②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手牌，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 怪兽效果①：把手牌的这张卡给对方观看才能发动。从手牌把1只怪兽里侧守备表示特殊召唤。这个效果发动的回合，自己不能把怪兽表侧表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 怪兽效果②：包含从卡组把卡加入手牌效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手牌。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.thcon2)
	e3:SetCost(s.thcost2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
	-- 怪兽效果③：这张卡反转的场合发动。对方手牌随机选1张直到结束阶段表侧表示除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	-- 添加自定义活动计数器，用于记录本回合是否特殊召唤过表侧表示怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤条件：只允许里侧表示特殊召唤
function s.counterfilter(c)
	return c:IsFacedown()
end
-- P效果①处理：为自身放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- P效果②Cost：支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分
	Duel.PayLPCost(tp,900)
end
-- 检索卡片过滤条件：属于「纠罪巧」系列且可加入手牌的卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- P效果②发动准备与目标确认：检查卡组是否存在至少3张满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少3张「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- P效果②处理：选3张「纠罪巧」卡确认，由对方随机选1张加入手牌，其余洗回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要展示加入手牌的3张卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 向对方展示选中的3张卡
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家选择要加入自己手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的1张卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽效果①Cost：展示手牌的此卡，并注册本回合不能表侧表示特召怪兽的誓约限制
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- Cost检查：确认本回合未曾表侧表示特殊召唤过怪兽
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册全局玩家限制效果：限制本回合只能里侧守备表示特殊召唤怪兽（不能表侧表示特召怪兽）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 向玩家注册不能表侧表示特殊召唤怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件：禁止表侧表示召唤/特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 特召卡片过滤条件：可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①发动准备与目标确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受限制里侧表示特召的效果（如神圣之光）影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查怪兽区域是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在可里侧守备表示特召的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①处理：从手牌选1只怪兽里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只可里侧守备表示特召的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将手牌洗牌
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中的怪兽里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若选中的怪兽原本公开，则向对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②发动条件检查：对方发动包含抽牌或检索效果且自身处于里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	return ep==1-tp and (ex4 or ex5) and e:GetHandler():IsFacedown()
end
-- 怪兽效果②Cost：把里侧表示的这张卡变成表侧守备表示
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将自身表示形式变更表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 检索过滤条件：卡组中可加入手牌的「纠罪巧」卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 怪兽效果②发动准备与目标确认
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可检索的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②处理：从卡组选1张「纠罪巧」卡加入手牌并确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果③发动准备与目标确认：确认对方手牌是否有可除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查对方手牌是否存在可除外的卡
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) then
		-- 获取对方手牌中可除外的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		-- 设置连锁操作信息：随机除外对方1张手牌
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 怪兽效果③处理：随机除外对方1张手牌直到结束阶段，并注册结束阶段归还手牌效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方手牌
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local rg=g:RandomSelect(1-tp,1)
	-- 将选中的手牌临时表侧表示除外
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		-- 获取成功除外的卡片集合
		local og=Duel.GetOperatedGroup()
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		local oc=og:GetFirst()
		oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
		og:KeepAlive()
		-- 注册结束阶段延迟生效效果：在回合结束阶段，将临时除外的对方手牌返回其手牌。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(og)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册结束阶段的归还手牌效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 归还卡片过滤条件：匹配注册标识FID的被除外卡片
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 归还效果条件判断：若存在符合条件的卡则生效，否则重置并清除效果
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 归还效果处理：将除外组中符合条件的卡送回原持有者的手牌
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	local tc=sg:GetFirst()
	-- 将目标卡送回原控制者的手牌
	Duel.SendtoHand(tc,tc:GetPreviousControler(),REASON_EFFECT)
end

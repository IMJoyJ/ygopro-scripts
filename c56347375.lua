--竜剣士イグニスP
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组（表侧）让1只灵摆怪兽回到卡组。那之后，除灵摆怪兽外的1只「龙剑士」怪兽或「点火骑士」怪兽从卡组加入手卡。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「点火骑士」卡使用。这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。除「龙剑士 点火烈·凤凰」外的1只「龙剑士」怪兽或「点火骑士」怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
function c56347375.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从自己的额外卡组（表侧）让1只灵摆怪兽回到卡组。那之后，除灵摆怪兽外的1只「龙剑士」怪兽或「点火骑士」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,56347375)
	e1:SetTarget(c56347375.thtg)
	e1:SetOperation(c56347375.thop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。除「龙剑士 点火烈·凤凰」外的1只「龙剑士」怪兽或「点火骑士」怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,56347376)
	e2:SetCondition(c56347375.spcon)
	e2:SetTarget(c56347375.sptg)
	e2:SetOperation(c56347375.spop)
	c:RegisterEffect(e2)
end
-- 过滤额外卡组中表侧表示且可以返回卡组的灵摆怪兽
function c56347375.tdfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToDeck()
end
-- 过滤卡组中除灵摆怪兽以外的「龙剑士」或「点火骑士」怪兽
function c56347375.thfilter(c)
	return c:IsSetCard(0xc7,0xc8) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果的发动准备与合法性检测
function c56347375.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组（表侧）是否存在至少1只可以返回卡组的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56347375.tdfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 并且检查卡组中是否存在至少1只可以加入手牌的非灵摆「龙剑士」或「点火骑士」怪兽
		and Duel.IsExistingMatchingCard(c56347375.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：将额外卡组的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁处理信息：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的处理逻辑
function c56347375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己额外卡组（表侧）选择1只满足条件的灵摆怪兽
	local tc=Duel.SelectMatchingCard(tp,c56347375.tdfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 如果成功将选择的怪兽送回卡组并洗牌
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只满足条件的非灵摆「龙剑士」或「点火骑士」怪兽
		local g=Duel.SelectMatchingCard(tp,c56347375.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的检索手牌处理与返回卡组不视为同时进行
			Duel.BreakEffect()
			-- 将选择的怪兽加入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 检查怪兽效果的发动条件：此卡在场上被战斗或效果破坏
function c56347375.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中除「龙剑士 点火烈·凤凰」外，可以特殊召唤的「龙剑士」或「点火骑士」怪兽
function c56347375.spfilter(c,e,tp)
	return c:IsSetCard(0xc7,0xc8) and not c:IsCode(56347375) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果的发动准备与合法性检测
function c56347375.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c56347375.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果的处理逻辑
function c56347375.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c56347375.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 尝试将选择的怪兽以表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽当作调整使用。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end

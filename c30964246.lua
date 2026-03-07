--ARG☆S－GiantKilling
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「阿尔戈☆群星」怪兽加入手卡。自己的怪兽区域有永续陷阱卡存在的场合或者持有把自身作为怪兽特殊召唤效果的永续陷阱卡在自己的魔法与陷阱区域存在的场合，可以再进行1只战士族怪兽的召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以包含自己场上的「阿尔戈☆群星」永续陷阱卡的场上2张卡为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 注册两个效果：①检索并可能召唤；②墓地发动，将场上2张卡送回手牌
function s.initial_effect(c)
	-- ①：从卡组把1只「阿尔戈☆群星」怪兽加入手卡。自己的怪兽区域有永续陷阱卡存在的场合或者持有把自身作为怪兽特殊召唤效果的永续陷阱卡在自己的魔法与陷阱区域存在的场合，可以再进行1只战士族怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND|CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以包含自己场上的「阿尔戈☆群星」永续陷阱卡的场上2张卡为对象才能发动。那些卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg1)
	e2:SetOperation(s.thop1)
	c:RegisterEffect(e2)
end
-- 过滤「阿尔戈☆群星」怪兽，可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1c1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时的检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「阿尔戈☆群星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1张卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤可通常召唤的战士族怪兽
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WARRIOR)
end
-- 过滤满足条件的永续陷阱卡（包括其特殊召唤效果）
function s.chkfilter(c)
	return c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsFaceup() and
		(c:IsLocation(LOCATION_MZONE) or
			-- 判断该永续陷阱卡是否具有特殊召唤效果
			c:IsEffectProperty(aux.EffectCategoryFilter(CATEGORY_SPECIAL_SUMMON)) and
			(c:GetOriginalLevel()>0
			or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
			or bit.band(c:GetOriginalAttribute(),0x7f)~=0
			or c:GetBaseAttack()>0
			or c:GetBaseDefense()>0))
end
-- 处理效果①：检索并可能召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查手牌或怪兽区域是否存在可通常召唤的战士族怪兽
		if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 检查场上是否存在满足条件的永续陷阱卡
			and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,nil)
			-- 询问玩家是否进行召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
			-- 提示玩家选择要召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择1张可通常召唤的战士族怪兽
			local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			if sg:GetCount()>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 进行通常召唤
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 过滤可送回手牌且可成为效果对象的卡
function s.filter(c,e)
	return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 过滤「阿尔戈☆群星」永续陷阱卡
function s.thfilters(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsSetCard(0x1c1)
end
-- 判断选中的卡组中是否存在「阿尔戈☆群星」永续陷阱卡
function s.sgselect(g,tp)
	return g:IsExists(s.thfilters,1,nil,tp)
end
-- 设置效果②：选择2张卡送回手牌
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取所有可送回手牌且可成为效果对象的卡
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.sgselect,2,2,tp) end
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.sgselect,false,2,2,tp)
	-- 设置效果处理的目标卡
	Duel.SetTargetCard(sg)
	-- 设置将目标卡送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
-- 处理效果②：将目标卡送回手牌
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的目标卡
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将目标卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

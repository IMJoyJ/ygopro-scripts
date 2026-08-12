--水霊媒師エリア
-- 效果：
-- 这个卡名在规则上也当作「灵使」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只水属性怪兽丢弃才能发动。把持有这张卡以外的丢弃的怪兽的等级以上的等级的1只水属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把水属性以外的怪兽的效果发动。
-- ②：自己的水属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：从手卡把这张卡和1只水属性怪兽丢弃才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的水属性怪兽被战斗破坏时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 用于判断手牌中是否存在满足条件的水属性可丢弃怪兽
function s.dfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
		-- 检查卡组中是否存在满足条件的水属性怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 用于筛选卡组中满足等级要求的水属性怪兽
function s.thfilter(c,lv)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(lv) and c:IsAbleToHand()
end
-- 效果发动时的费用处理，丢弃手牌并选择目标怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足丢弃手牌的条件
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,c,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的水属性怪兽丢弃
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,c,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选中的怪兽丢入墓地作为费用
	Duel.SendtoGrave(g+c,REASON_COST+REASON_DISCARD)
end
-- 设置检索效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查卡组中是否存在满足条件的水属性怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置检索效果的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，将符合条件的怪兽加入手牌并设置不能发动非水属性怪兽效果的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的水属性怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 设置发动①效果后，直到回合结束时自己不能把水属性以外的怪兽的效果发动
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能发动效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能发动的效果条件：非水属性的怪兽效果
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_WATER)
end
-- 用于判断被破坏的怪兽是否为水属性
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp)
end
-- 判断是否满足②效果发动条件：己方水属性怪兽被战斗破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置②效果的特殊召唤目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行②效果的特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否还在场上，若在则进行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end

--大翼のバフォメット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。兽族·4星怪兽以及「合成兽融合」各最多1张从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册召唤成功时触发的检索效果e1、特召成功时触发的检索效果e2（e1的克隆），以及作为素材送去墓地时触发的特殊召唤效果e3
function s.initial_effect(c)
	-- 记录该卡记载了「合成兽融合」的卡名
	aux.AddCodeList(c,63136489)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。兽族·4星怪兽以及「合成兽融合」各最多1张从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检索卡片的过滤函数：检测是否为4星兽族怪兽或「合成兽融合」且可加入手卡
function s.filter(c)
	return (c:IsLevel(4) and c:IsRace(RACE_BEAST) or c:IsCode(63136489)) and c:IsAbleToHand()
end
-- 检索效果的Target函数：检测卡组是否存在可检索的卡片，并设置检索与加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检测阶段，检查卡组中是否存在满足检索条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组中的卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检查选卡组是否满足“各最多1张”（即4星兽族怪兽小于2张，且「合成兽融合」小于2张）
function s.check(g)
	return g:FilterCount(Card.IsLevel,nil,4)<2 and g:FilterCount(Card.IsCode,nil,63136489)<2
end
-- 检索效果的Operation函数：从卡组将兽族·4星怪兽以及「合成兽融合」各最多1张加入手卡，并设置直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有可以检索的卡片组
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=tg:SelectSubGroup(tp,s.check,false,1,2)
	if g then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。②：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制自己不能特殊召唤融合怪兽以外怪兽的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数：限制自己不能从额外卡组特殊召唤融合怪兽以外的怪兽
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 特殊召唤效果的Condition函数：检测这张卡是否作为融合召唤素材送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 特殊召唤怪兽的过滤函数：检测是否为幻想魔族怪兽且可以特殊召唤
function s.sfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target函数：检测自己场上是否有空怪兽区域，墓地是否有幻想魔族怪兽，并选择1只幻想魔族怪兽作为对象，设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 在检测阶段，检查己方主要怪兽区域是否还有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的墓地是否存在至少1张满足特殊召唤条件的幻想魔族怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择作为特殊召唤对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择1只幻想魔族怪兽作为连锁的对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤作为对象的幻想魔族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的Operation函数：将墓地中作为对象的幻想魔族怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中作为对象的幻想魔族怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果作为对象的幻想魔族怪兽与效果有关，将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

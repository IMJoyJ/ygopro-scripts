--BF－刻夜のゾンダ
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：只要这张卡在怪兽区域存在，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
-- ③：把墓地的这张卡除外才能发动。从手卡·卡组把1只5星以上的「黑羽」怪兽特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽的攻击力数值的伤害。
function c7459919.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c7459919.splimit)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7459919,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,7459919)
	e2:SetTarget(c7459919.thtg)
	e2:SetOperation(c7459919.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。从手卡·卡组把1只5星以上的「黑羽」怪兽特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽的攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(7459919,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,7459919)
	-- 将墓地的这张卡除外作为发动的代价
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c7459919.sptg)
	e4:SetOperation(c7459919.spop)
	c:RegisterEffect(e4)
end
-- 限制只能从额外卡组特殊召唤同调怪兽
function c7459919.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②（弹手牌）的发动准备与目标选择
function c7459919.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 在发动时，检查场上是否存在可以回到手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只可以回到手牌的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②（弹手牌）的效果处理
function c7459919.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤手牌或卡组中可以特殊召唤的5星以上的「黑羽」怪兽
function c7459919.spfilter(c,e,tp)
	return c:IsSetCard(0x33) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（特召并受伤害）的发动准备
function c7459919.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手牌或卡组中存在可以特殊召唤的5星以上「黑羽」怪兽
		and Duel.IsExistingMatchingCard(c7459919.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息为从手牌或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
	-- 设置效果处理信息为玩家受到伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end
-- 效果③（特召并受伤害）的效果处理
function c7459919.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组选择1只满足条件的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c7459919.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断效果处理，使后续的伤害处理不与特殊召唤同时进行（防止错时点）
		Duel.BreakEffect()
		-- 自己受到该特殊召唤怪兽攻击力数值的伤害
		Duel.Damage(tp,tc:GetAttack(),REASON_EFFECT)
	end
end

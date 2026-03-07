--常夏のカミナリサマー
-- 效果：
-- 雷族怪兽2只
-- ①：对方回合1次，丢弃1张手卡，以连接怪兽以外的自己墓地1只雷族怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c38406364.initial_effect(c)
	-- 为卡片添加连接召唤手续，使用至少2个且至多2个满足雷族条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_THUNDER),2,2)
	c:EnableReviveLimit()
	-- ①：对方回合1次，丢弃1张手卡，以连接怪兽以外的自己墓地1只雷族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(38406364,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c38406364.spcon)
	e1:SetCost(c38406364.spcost)
	e1:SetTarget(c38406364.sptg)
	e1:SetOperation(c38406364.spop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方回合
function c38406364.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不等于效果发动玩家
	return Duel.GetTurnPlayer()~=tp
end
-- 设置效果的发动费用，丢弃1张手卡
function c38406364.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义过滤函数，筛选满足雷族、非连接怪兽且可特殊召唤的墓地怪兽
function c38406364.filter(c,e,tp,zone)
	return c:IsRace(RACE_THUNDER) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置效果的目标选择函数，选择满足条件的墓地怪兽
function c38406364.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38406364.filter(chkc,e,tp,zone) end
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地目标怪兽
		and Duel.IsExistingTarget(c38406364.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c38406364.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置效果的处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置效果的处理函数，将目标怪兽特殊召唤到场上
function c38406364.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽以正面表示的形式特殊召唤到指定区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

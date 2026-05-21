--B・F－早撃ちのアルバレスト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只3星以下的昆虫族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡被对方破坏的场合才能发动。从手卡·卡组把1只「蜂军」怪兽特殊召唤。
function c90161770.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只3星以下的昆虫族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90161770,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c90161770.sumtg)
	e1:SetOperation(c90161770.sumop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被对方破坏的场合才能发动。从手卡·卡组把1只「蜂军」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90161770,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,90161770)
	e2:SetCondition(c90161770.spcon)
	e2:SetTarget(c90161770.sptg)
	e2:SetOperation(c90161770.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地3星以下的昆虫族怪兽且能守备表示特殊召唤
function c90161770.spfilter1(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与目标选择
function c90161770.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90161770.spfilter1(chkc,e,tp) end
	-- 检查自己墓地是否存在满足条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c90161770.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 且自身怪兽区域有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90161770.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤操作，对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理：将选择的怪兽守备表示特殊召唤
function c90161770.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧守备表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：这张卡被对方破坏且原本控制权为自己
function c90161770.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤条件：手牌·卡组中可以特殊召唤的「蜂军」怪兽
function c90161770.spfilter2(c,e,tp)
	return c:IsSetCard(0x12f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与连锁信息设置
function c90161770.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手牌或卡组中存在至少1只满足条件的「蜂军」怪兽
		and Duel.IsExistingMatchingCard(c90161770.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手牌·卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的处理：从手牌·卡组将1只「蜂军」怪兽特殊召唤
function c90161770.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自身怪兽区域没有空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择1只满足条件的「蜂军」怪兽
	local g=Duel.SelectMatchingCard(tp,c90161770.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

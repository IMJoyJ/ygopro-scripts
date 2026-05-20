--極星獣グリンブルスティ
-- 效果：
-- 这张卡可以作为「极星」调整的代替而成为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只「极星」怪兽特殊召唤。
-- ②：以「极星兽 古林布尔斯提」以外的自己墓地1只「极星」怪兽为对象才能发动。那只怪兽加入手卡。
function c65626958.initial_effect(c)
	-- 这张卡可以作为「极星」调整的代替而成为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(61777313)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只「极星」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,65626958)
	e2:SetTarget(c65626958.sptg)
	e2:SetOperation(c65626958.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：以「极星兽 古林布尔斯提」以外的自己墓地1只「极星」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,65626959)
	e4:SetTarget(c65626958.thtg)
	e4:SetOperation(c65626958.thop)
	c:RegisterEffect(e4)
end
-- 过滤手牌中可以特殊召唤的「极星」怪兽
function c65626958.spfilter(c,e,tp)
	return c:IsSetCard(0x42) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果（召唤·特殊召唤成功时发动）的发动条件检查与操作信息设置
function c65626958.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只可以特殊召唤的「极星」怪兽
		and Duel.IsExistingMatchingCard(c65626958.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为“从手牌特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果（召唤·特殊召唤成功时发动）的效果处理
function c65626958.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的「极星」怪兽
	local g=Duel.SelectMatchingCard(tp,c65626958.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己墓地中「极星兽 古林布尔斯提」以外的「极星」怪兽
function c65626958.thfilter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and not c:IsCode(65626958) and c:IsAbleToHand()
end
-- ②效果（回收墓地极星怪兽）的发动条件检查、选择对象与操作信息设置
function c65626958.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c65626958.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的、除「极星兽 古林布尔斯提」以外的「极星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c65626958.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的「极星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65626958.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理中的操作信息为“将选中的对象卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果（回收墓地极星怪兽）的效果处理
function c65626958.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

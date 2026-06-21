--未界域のチュパカブラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的卓柏卡布拉」以外的场合，再从手卡把1只「未界域的卓柏卡布拉」特殊召唤，自己抽1张。
-- ②：这张卡从手卡丢弃的场合，以「未界域的卓柏卡布拉」以外的自己墓地1只「未界域」怪兽为对象才能发动。那只怪兽特殊召唤。
function c16209941.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的卓柏卡布拉」以外的场合，再从手卡把1只「未界域的卓柏卡布拉」特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16209941,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c16209941.spcost)
	e1:SetTarget(c16209941.sptg)
	e1:SetOperation(c16209941.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从手卡丢弃的场合，以「未界域的卓柏卡布拉」以外的自己墓地1只「未界域」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16209941,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,16209941)
	e2:SetTarget(c16209941.sptg2)
	e2:SetOperation(c16209941.spop2)
	c:RegisterEffect(e2)
end
-- 检查手牌中的这张卡是否处于未公开状态（展示自身作为cost的前置检查）
function c16209941.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：检查卡片是否为「未界域的卓柏卡布拉」且可以特殊召唤
function c16209941.spfilter(c,e,tp)
	return c:IsCode(16209941) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检测与操作信息设置（检查是否有可丢弃的手牌，并设置丢弃自己手牌的操作信息）
function c16209941.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在可以被效果丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置自己丢弃1张手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①效果的处理：对方随机挑选1张手卡丢弃，若丢弃的不是「未界域的卓柏卡布拉」，则特殊召唤手牌的1只「未界域的卓柏卡布拉」并自己抽1张
function c16209941.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己全部的手牌
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()<=0 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 将随机选中的手卡丢弃，并判断该卡是否不是「未界域的卓柏卡布拉」
	if Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(16209941)
		-- 并且检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己手卡中所有符合特殊召唤条件的「未界域的卓柏卡布拉」
		local spg=Duel.GetMatchingGroup(c16209941.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断效果处理，使后续的处理与丢弃手牌处理不同时进行（避免影响时点）
		Duel.BreakEffect()
		-- 若特殊召唤成功，则进行后续的效果处理
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 自己从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤函数：检查卡片是否为「未界域的卓柏卡布拉」以外的「未界域」怪兽，且可以特殊召唤
function c16209941.spfilter2(c,e,tp)
	return c:IsSetCard(0x11e) and not c:IsCode(16209941) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动检测（包括对象合法性判定与可用怪兽区域的检查）
function c16209941.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16209941.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在可以特殊召唤的目标「未界域」怪兽
		and Duel.IsExistingTarget(c16209941.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「未界域的卓柏卡布拉」以外的「未界域」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c16209941.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤该目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：特殊召唤作为效果对象的目标怪兽
function c16209941.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果所针对的第一个对象（即被选中的墓地怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽正面表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

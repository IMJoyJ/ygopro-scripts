--未界域のチュパカブラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的卓柏卡布拉」以外的场合，再从手卡把1只「未界域的卓柏卡布拉」特殊召唤，自己抽1张。
-- ②：这张卡从手卡丢弃的场合，以「未界域的卓柏卡布拉」以外的自己墓地1只「未界域」怪兽为对象才能发动。那只怪兽特殊召唤。
function c16209941.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的卓柏卡布拉」以外的场合，再从手卡把1只「未界域的卓柏卡布拉」特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16209941,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c16209941.spcost)
	e1:SetTarget(c16209941.sptg)
	e1:SetOperation(c16209941.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合，以「未界域的卓柏卡布拉」以外的自己墓地1只「未界域」怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 检查是否公开手卡
function c16209941.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手卡中可特殊召唤的「未界域的卓柏卡布拉」
function c16209941.spfilter(c,e,tp)
	return c:IsCode(16209941) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理信息，准备丢弃手卡
function c16209941.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置丢弃手卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 处理①效果的主要流程：随机选择对方手卡并丢弃，若非卓柏卡布拉则特殊召唤一只卓柏卡布拉并抽一张牌
function c16209941.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()<=0 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 将选中的卡送去墓地并判断是否为卓柏卡布拉
	if Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(16209941)
		-- 检查场上是否有特殊召唤空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取手卡中可特殊召唤的卓柏卡布拉
		local spg=Duel.GetMatchingGroup(c16209941.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选中的卓柏卡布拉特殊召唤
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 抽一张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤墓地中可特殊召唤的「未界域」怪兽（非卓柏卡布拉）
function c16209941.spfilter2(c,e,tp)
	return c:IsSetCard(0x11e) and not c:IsCode(16209941) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的目标选择函数
function c16209941.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16209941.spfilter2(chkc,e,tp) end
	-- 检查场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合条件的「未界域」怪兽
		and Duel.IsExistingTarget(c16209941.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c16209941.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理②效果的主要流程：选择墓地中的「未界域」怪兽并特殊召唤
function c16209941.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--オッドアイズ・アークペンデュラム・ドラゴン
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的表侧表示的「异色眼」卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「异色眼」怪兽特殊召唤。
-- 【怪兽描述】
-- 雄壮而又美丽的拥有神秘之眼的奇迹之龙。那闪耀着双色光辉的眼睛，映出描绘于天空之中的轨迹。
function c14105623.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的表侧表示的「异色眼」卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「异色眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14105623,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,14105623)
	e1:SetCondition(c14105623.spcon)
	e1:SetTarget(c14105623.sptg)
	e1:SetOperation(c14105623.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断被破坏的卡是否为「异色眼」卡且满足破坏条件
function c14105623.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0x99)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果发动条件函数，判断是否有满足条件的「异色眼」卡被破坏
function c14105623.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14105623.cfilter,1,nil,tp)
end
-- 过滤函数，用于筛选可以特殊召唤的「异色眼」怪兽
function c14105623.spfilter(c,e,tp)
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动目标设定函数，检查是否满足发动条件并设置操作信息
function c14105623.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查手牌·卡组·墓地是否存在满足条件的「异色眼」怪兽
		and Duel.IsExistingMatchingCard(c14105623.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的卡的来源位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果的发动处理函数，执行特殊召唤操作
function c14105623.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足处理条件，包括是否有足够的召唤位置和该卡是否仍在场上
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌·卡组·墓地选择满足条件的「异色眼」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c14105623.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

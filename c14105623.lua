--オッドアイズ・アークペンデュラム・ドラゴン
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的表侧表示的「异色眼」卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「异色眼」怪兽特殊召唤。
-- 【怪兽描述】
-- 雄壮而又美丽的拥有神秘之眼的奇迹之龙。那闪耀着双色光辉的眼睛，映出描绘于天空之中的轨迹。
function c14105623.initial_effect(c)
	-- 为灵摆怪兽c注册灵摆召唤/灵摆卡发动等灵摆属性，使该卡能作为灵摆卡放置在灵摆区并发动灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- 对应效果原文：“这个卡名的灵摆效果1回合只能使用1次。①：自己场上的表侧表示的「异色眼」卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「异色眼」怪兽特殊召唤。”；本段代码创建并注册了该诱发效果，包含次数限制、条件、对象与处理。
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
-- 筛选被破坏的卡：必须是因战斗或效果被破坏、破坏前为表侧表示且位于场上、控制者为我方、并且卡名含有「异色眼」字段。
function c14105623.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0x99)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 诱发条件：当破坏事件中被破坏的怪兽集合中存在至少1张满足cfilter条件的卡，即我方场上表侧表示的「异色眼」卡被战斗·效果破坏。
function c14105623.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14105623.cfilter,1,nil,tp)
end
-- 特殊召唤候选的筛选：卡名含有「异色眼」字段，并且能够被我方用该效果特殊召唤（不检查召唤条件与苏生限制）。
function c14105623.spfilter(c,e,tp)
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的合法性检查：我方主要怪兽区有空位，且手卡·卡组·墓地中存在至少1只满足条件的「异色眼」怪兽可以特殊召唤。
function c14105623.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空格，确保有格子进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地中是否存在至少1只满足spfilter条件的「异色眼」怪兽。
		and Duel.IsExistingMatchingCard(c14105623.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本连锁的操作信息为特殊召唤，预计从手卡·卡组·墓地特殊召唤1只怪兽（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：确认仍有格子且发动的灵摆卡仍与效果关联；提示玩家选择要特殊召唤的卡；从手卡·卡组·墓地中选出1只「异色眼」怪兽并表侧表示特殊召唤。
function c14105623.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前安全判定：若我方主要怪兽区没有空位，或灵摆区的这张卡已离场/与效果失去关联，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 向操作玩家发送选择提示消息，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·墓地中选择1只满足spfilter的「异色眼」怪兽；使用王家长眠之谷过滤器，若该卡受王家长眠之谷影响则不能选择。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c14105623.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「异色眼」怪兽以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

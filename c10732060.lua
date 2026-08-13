--HSRグライダー2
-- 效果：
-- 机械族·风属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以除调整外的自己墓地1只7星以下的风属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，若自己场上有「幻透翼」怪兽存在，把墓地的这张卡除外才能发动。对方场上的全部怪兽的等级上升5星。
local s,id,o=GetID()
-- 初始化效果：为这张卡添加同调召唤手续、苏生限制，并注册①与②两个效果的触发、条件、目标与处理。
function s.initial_effect(c)
	-- 为这张卡设置同调召唤手续：素材为机械族·风属性调整1只＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,s.sfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以除调整外的自己墓地1只7星以下的风属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽特殊召唤的场合，若自己场上有「幻透翼」怪兽存在，把墓地的这张卡除外才能发动。对方场上的全部怪兽的等级上升5星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.lvcon)
	-- 设置效果2的发动代价为把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 定义同调素材中“调整”的过滤条件：必须是机械族且风属性的怪兽。
function s.sfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 定义效果1的发动条件：这张卡进行过同调召唤（即同调召唤成功）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义效果1的对象过滤条件：不是调整、是同调怪兽、等级7以下、风属性、并且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(7)
		and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的发动阶段：先校验对象卡是否满足条件；再检查自己场上是否有空位、墓地是否有符合条件的对象可供选择。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上的主要怪兽区是否有空余位置，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足s.spfilter条件的风属性同调怪兽，且该怪兽能成为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的风属性同调怪兽作为效果对象，并设置为该连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将进行特殊召唤，处理对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果1处理：取得对象怪兽，若其仍与效果关联且不受王家长眠之谷影响，则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中登记的对象卡（即选择要特殊召唤的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍然与当前效果相关，并且不受王家长眠之谷的墓地效果限制。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤条件：场上存在表侧表示的「幻透翼」怪兽（setcode 0xff）。
function s.cfilter(c)
	return c:IsSetCard(0xff) and c:IsFaceup()
end
-- 定义效果2的发动条件：对方在这次特殊召唤成功的事件中召唤了怪兽（存在召唤玩家为对方的情况）。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义效果2处理时的对象过滤条件：怪兽必须是表侧表示且当前等级大于0。
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果2的发动检查：对方场上有表侧表示且等级大于0的怪兽，同时自己场上存在表侧表示的「幻透翼」怪兽。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且等级大于0的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示的「幻透翼」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果2处理：使对方场上的全部表侧表示且等级大于0的怪兽等级上升5星。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上所有表侧表示且等级大于0的怪兽。
	local tg=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历取到的每只对方怪兽，逐一附加等级上升效果。
	for tc in aux.Next(tg) do
		-- 对方场上的全部怪兽的等级上升5星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
	end
end

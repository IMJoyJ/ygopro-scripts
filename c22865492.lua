--V・HERO インクリース
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
-- ③：这张卡从魔法与陷阱区域特殊召唤的场合才能发动。从卡组把1只4星以下的「幻影英雄」怪兽特殊召唤。
function c22865492.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22865492,0))  --"这张卡当作永续陷阱卡放置"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,22865492)
	e1:SetCondition(c22865492.condition)
	e1:SetTarget(c22865492.target)
	e1:SetOperation(c22865492.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22865492,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,22865493)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(c22865492.spcon1)
	e2:SetCost(c22865492.spcost1)
	e2:SetTarget(c22865492.sptg1)
	e2:SetOperation(c22865492.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从魔法与陷阱区域特殊召唤的场合才能发动。从卡组把1只4星以下的「幻影英雄」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22865492,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,22865494)
	e3:SetCondition(c22865492.spcon2)
	e3:SetTarget(c22865492.sptg2)
	e3:SetOperation(c22865492.spop2)
	c:RegisterEffect(e3)
end
-- 效果发动条件：受到伤害的玩家是这张卡的控制者，且该伤害的原因包含战斗伤害或效果伤害。
function c22865492.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 发动时的目标处理：检查自己的魔法与陷阱区域是否有空位，并把本次操作标记为这张卡从墓地离开。
function c22865492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：自己的魔法与陷阱区域还有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 登记操作信息：这张卡会被从墓地移动，数量为1，用于王家长眠之谷等相关效果的判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与该效果关联，则把这张卡从墓地以表侧表示放到自己的魔法与陷阱区域，并使其种类变成永续陷阱。
function c22865492.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示移动到自己的魔法与陷阱区域，并立刻适用其效果；移动成功时继续后续处理。
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：当前是主要阶段，且这张卡在魔法与陷阱区域中被当作永续陷阱卡使用。
function c22865492.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于自己或对方的主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 用于选择可解放怪兽的过滤器：该怪兽拥有「英雄」字段，解放后自己仍留有可用怪兽区，并且是表侧表示或由自己控制的怪兽。
function c22865492.cfilter1(c,tp)
	-- 判断怪兽具有「英雄」字段、解放后仍有怪兽区空位，并且是表侧表示或由自己控制。
	return c:IsSetCard(0x8) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- ②效果发动代价：从自己场上选择1只满足条件的「英雄」怪兽解放；先检查是否存在可解放对象，再选择并解放。
function c22865492.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己场上是否存在至少1只可作为代价解放的「英雄」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22865492.cfilter1,1,nil,tp) end
	-- 选择1只满足条件的「英雄」怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c22865492.cfilter1,1,1,nil,tp)
	-- 将选择的怪兽解放，解放原因为COST，不计入效果处理。
	Duel.Release(g,REASON_COST)
end
-- 发动时判断自己能否把这张卡本身特殊召唤，并登记本次特殊召唤的操作信息。
function c22865492.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家能否把这张卡（22865492）作为暗属性·战士族·3星·攻击力900/守备力1100的效果怪兽以表侧表示特殊召唤。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,22865492,0x5008,TYPE_MONSTER+TYPE_EFFECT,900,1100,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 登记操作信息：本次特殊召唤的对象是e:GetHandler()，即这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与该效果关联，则把它从魔法与陷阱区域以表侧表示特殊召唤。
function c22865492.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件：这张卡特殊召唤成功，且特殊召唤前所在位置是魔法与陷阱区域（不是场地区域）。
function c22865492.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 用于选择卡组怪兽的过滤器：等级4以下、属于「幻影英雄」字段，并且可以被当前效果特殊召唤。
function c22865492.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x5008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动判定：自己怪兽区有空位，并且卡组中存在1只符合条件的「幻影英雄」怪兽。
function c22865492.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己的怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定卡组中是否存在1只满足spfilter2条件的「幻影英雄」怪兽。
		and Duel.IsExistingMatchingCard(c22865492.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：预定从卡组特殊召唤1只怪兽，目标不取对象，在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：若怪兽区仍有空位，则提示玩家从卡组选择1只符合条件的「幻影英雄」怪兽，并以表侧表示特殊召唤。
function c22865492.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认怪兽区有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发出特殊召唤选择提示，显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组选择1只满足spfilter2条件的「幻影英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,c22865492.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

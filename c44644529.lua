--双天の転身
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，比那只怪兽原本等级高1星或者原本等级低1星的1只「双天」怪兽从卡组·额外卡组特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c44644529.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，比那只怪兽原本等级高1星或者原本等级低1星的1只「双天」怪兽从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,44644529)
	e1:SetTarget(c44644529.target)
	e1:SetOperation(c44644529.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44644529,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,44644530)
	e2:SetCondition(c44644529.thcon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外，即调用aux.bfgcost实现除外自身作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44644529.thtg)
	e2:SetOperation(c44644529.thop)
	c:RegisterEffect(e2)
end
-- ①效果的取对象筛选：判定场上表侧表示且属于「双天」字段、原本等级大于0的怪兽，同时还需保证卡组·额外卡组中存在与破坏后等级差1的「双天」怪兽可供特殊召唤，以此作为能否选取为对象的条件。
function c44644529.desfilter(c,e,tp)
	local lv=c:GetOriginalLevel()
	-- 判定怪兽是否满足：表侧表示、属于「双天」字段、原本等级大于0，并且卡组/额外卡组中有1只可特殊召唤的符合条件的「双天」怪兽（该怪兽等级需为目标怪兽原本等级±1）。
	return c:IsFaceup() and c:IsSetCard(0x14f) and lv>0 and Duel.IsExistingMatchingCard(c44644529.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,lv,c)
end
-- ①效果特殊召唤候选的过滤：必须是「双天」怪兽，等级在目标怪兽原本等级±1范围内，且满足特殊召唤条件；若从卡组特招需有主怪兽区空格，若从额外卡组特招需有额外卡组怪兽可用的空格。
function c44644529.spfilter(c,e,tp,lv,rc)
	if not (c:IsSetCard(0x14f) and c:IsLevel(lv-1,lv+1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		-- 检查从卡组特殊召唤时，目标怪兽被破坏后自己场上是否仍有可用的主怪兽区空格。
		return Duel.GetMZoneCount(tp,rc)>0
	else
		-- 检查从额外卡组特殊召唤时，目标怪兽被破坏后自己场上是否有足够的空格来特殊召唤额外怪兽。
		return Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
	end
end
-- ①效果的发动时点处理：若为选择对象确认（chkc）则校验对象是否为自己场上满足desfilter的「双天」怪兽；在发动合法性检查中确认场上存在1只可取对象；然后提示玩家选择要破坏的怪兽，将其设为对象，并设置破坏及特殊召唤的操作信息。
function c44644529.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44644529.desfilter(chkc,e,tp) end
	-- 发动时合法性判定：确认自己场上存在至少1只满足条件的「双天」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c44644529.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向操作玩家发出选择提示，提示文本为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只满足条件的「双天」怪兽作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44644529.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁包含破坏效果，破坏对象为g中的这只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本连锁包含特殊召唤效果，特殊召唤的卡在效果处理时才确定，预计从卡组·额外卡组特殊召唤1只「双天」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果处理：取回对象，确认其仍与效果关联后将其破坏；破坏成功时，从卡组/额外卡组选择1只等级为目标怪兽原本等级±1的「双天」怪兽以表侧表示特殊召唤。
function c44644529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁的第一个对象，即①效果发动时选择要破坏的「双天」怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍与效果关联，则用效果将其破坏；只有破坏成功时才继续执行特殊召唤处理。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 向玩家发出选择提示，提示文本为‘请选择要特殊召唤的卡’。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组·额外卡组选择1只可特殊召唤、等级为被破坏怪兽原本等级±1的「双天」怪兽。
		local sg=Duel.SelectMatchingCard(tp,c44644529.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetOriginalLevel())
		if #sg>0 then
			-- 将选中的「双天」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件：不是这张卡送去墓地的回合（aux.exccon检查），且当前为持有者的主要阶段1或主要阶段2。
function c44644529.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回②效果可否发动的判定：满足‘不是送去墓地的回合’且当前为持有者的主要阶段（PHASE_MAIN1/PHASE_MAIN2）。
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ②效果取对象过滤：对象必须是墓地中的「双天」怪兽卡，且能够被加入手卡（未受‘不能加入手卡’限制）。
function c44644529.thfilter(c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标选择：从自己墓地选择1只满足条件的「双天」怪兽作为对象，并设置加入手卡的操作信息。
function c44644529.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44644529.thfilter(chkc) end
	-- 发动合法性判定：确认自己墓地存在至少1只满足条件的「双天」怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c44644529.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示，提示文本为‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的「双天」怪兽作为②效果的对象。
	local g=Duel.SelectTarget(tp,c44644529.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本连锁包含加入手卡效果，目标为g中的这张怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取回目标怪兽，若其仍与效果关联则将其加入持有者的手卡。
function c44644529.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果处理时的目标怪兽，即从墓地选择的对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将选中的「双天」怪兽加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

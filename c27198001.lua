--九尾の狐
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
-- ②：从墓地特殊召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡被战斗·效果破坏送去墓地的场合才能发动。在自己场上把2只「狐衍生物」（不死族·炎·2星·攻/守500）特殊召唤。
function c27198001.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,27198001)
	e1:SetCost(c27198001.spcost)
	e1:SetTarget(c27198001.sptg)
	e1:SetOperation(c27198001.spop)
	c:RegisterEffect(e1)
	-- ②：从墓地特殊召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c27198001.pcon)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合才能发动。在自己场上把2只「狐衍生物」（不死族·炎·2星·攻/守500）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c27198001.condition)
	e3:SetTarget(c27198001.target)
	e3:SetOperation(c27198001.operation)
	c:RegisterEffect(e3)
end
-- 作为①效果的发动代价，选择自己场上2只怪兽解放；同时检查解放后场上是否有空位并处理代替解放的次数。
function c27198001.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得当前玩家场上可用于解放的怪兽组。
	local rg=Duel.GetReleaseGroup(tp)
	-- 检查是否存在2只可解放的怪兽，且解放后主怪兽区仍有空位（用于放置九尾狐）。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 向玩家显示“请选择要解放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足条件（解放后仍有空位）的怪兽作为解放代价。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 若选择了带有代替解放效果的怪兽（如暗影敌托邦类效果），则消耗其额外的解放次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的怪兽作为代价解放（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ①效果的发动目标与合法性判定：确认九尾狐能够特殊召唤，并登记特殊召唤操作信息。
function c27198001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记效果处理时将特殊召唤这张九尾狐（数量1）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时的特殊召唤：若九尾狐仍与效果关联，则将其特殊召唤。
function c27198001.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将九尾狐以表侧攻击表示特殊召唤到其持有者（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②贯穿伤害的适用条件：这张九尾狐是从墓地特殊召唤的（召唤·特殊召唤的位置为墓地）。
function c27198001.pcon(e)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- ③效果的发动条件：这张九尾狐被战斗或效果破坏并送去墓地。
function c27198001.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ③效果的发动目标判定：玩家可以特殊召唤2只狐衍生物，且主怪兽区空位足够，并且不受“青眼精灵龙”等禁止同时特殊召唤2只以上怪兽的效果影响。
function c27198001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够特殊召唤狐衍生物（不死族·炎·2星·攻/守500的衍生物）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,27198002,0,TYPES_TOKEN_MONSTER,500,500,2,RACE_ZOMBIE,ATTRIBUTE_FIRE)
		-- 检查自己的主怪兽区空位数量大于1，确保能放置2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 登记操作信息：本效果将生成2只衍生物（对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 登记操作信息：本效果将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ③效果处理时先进行条件判定：主怪兽区空位不足2个、受“青眼精灵龙”效果影响、或玩家不能特殊召唤狐衍生物时，直接终止处理。
function c27198001.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 主怪兽区可用空位不足2个时，终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 玩家不能特殊召唤狐衍生物时，终止特殊召唤处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,27198002,0,TYPES_TOKEN_MONSTER,500,500,2,RACE_ZOMBIE,ATTRIBUTE_FIRE) then return end
	for i=1,2 do
		-- 创建1只“狐衍生物”（卡号27198002）在玩家tp的场上（衍生物生成）。
		local token=Duel.CreateToken(tp,27198002)
		-- 将这只衍生物以表侧表示加入特殊召唤处理流程（暂不实际特殊召唤）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有特殊召唤步骤，将之前暂存的衍生物一并特殊召唤到场上。
	Duel.SpecialSummonComplete()
end

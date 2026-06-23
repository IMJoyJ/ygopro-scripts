--九尾の狐
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
-- ②：从墓地特殊召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡被战斗·效果破坏送去墓地的场合才能发动。在自己场上把2只「狐衍生物」（不死族·炎·2星·攻/守500）特殊召唤。
function c27198001.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
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
-- 检索满足条件的卡片组并检查是否可以解放2只怪兽以满足特殊召唤条件
function c27198001.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的卡片组
	local rg=Duel.GetReleaseGroup(tp)
	-- 检查是否可以选出2只符合条件的怪兽进行解放
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择2只符合条件的怪兽进行解放
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 强制使用代替解放效果次数
	aux.UseExtraReleaseCount(g,tp)
	-- 实际解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 检查此卡是否可以被特殊召唤
function c27198001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c27198001.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否从墓地特殊召唤
function c27198001.pcon(e)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 判断此卡是否因战斗或效果破坏而送去墓地
function c27198001.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 检查是否可以特殊召唤2只狐衍生物
function c27198001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以特殊召唤狐衍生物
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,27198002,0,TYPES_TOKEN_MONSTER,500,500,2,RACE_ZOMBIE,ATTRIBUTE_FIRE)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 设置操作信息，表示将召唤2只狐衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将特殊召唤2只狐衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 检查是否满足召唤狐衍生物的条件
function c27198001.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否可以特殊召唤狐衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,27198002,0,TYPES_TOKEN_MONSTER,500,500,2,RACE_ZOMBIE,ATTRIBUTE_FIRE) then return end
	for i=1,2 do
		-- 创建一只狐衍生物
		local token=Duel.CreateToken(tp,27198002)
		-- 将狐衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤操作
	Duel.SpecialSummonComplete()
end

--魂のさまよう墓場
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡已在魔法与陷阱区域存在的状态，自己场上的怪兽被战斗破坏送去墓地的场合发动。在自己场上把1只「火之玉衍生物」（炎族·炎·1星·攻/守100）特殊召唤。
-- ②：这张卡已在魔法与陷阱区域存在的状态，自己的手卡·场上的怪兽被对方的效果送去墓地的场合发动。把最多有那些怪兽数量的「火之玉衍生物」尽可能在自己场上特殊召唤。
function c98596596.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡已在魔法与陷阱区域存在的状态，自己场上的怪兽被战斗破坏送去墓地的场合发动。在自己场上把1只「火之玉衍生物」（炎族·炎·1星·攻/守100）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c98596596.spcon1)
	e2:SetTarget(c98596596.sptg1)
	e2:SetOperation(c98596596.spop1)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡已在魔法与陷阱区域存在的状态，自己的手卡·场上的怪兽被对方的效果送去墓地的场合发动。把最多有那些怪兽数量的「火之玉衍生物」尽可能在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,98596596)
	e3:SetCondition(c98596596.spcon2)
	e3:SetTarget(c98596596.sptg2)
	e3:SetOperation(c98596596.spop2)
	c:RegisterEffect(e3)
end
-- 过滤被战斗破坏送去自己墓地的自己场上的怪兽
function c98596596.cfilter1(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 效果①的发动条件：自己场上的怪兽被战斗破坏送去墓地，且这张卡已在魔陷区表侧表示存在
function c98596596.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c98596596.cfilter1,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果①的靶向函数：检查怪兽区域空位以及是否能特殊召唤衍生物，并设置操作信息
function c98596596.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤特定属性和数值的「火之玉衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,23116809,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PYRO,ATTRIBUTE_FIRE) end
	-- 设置连锁的操作信息：特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁的操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理：在自己场上特殊召唤1只「火之玉衍生物」
function c98596596.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍在场上，以及自己场上是否有可用的怪兽区域空位，若不满足则不处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认玩家当前是否仍能特殊召唤「火之玉衍生物」
	if Duel.IsPlayerCanSpecialSummonMonster(tp,23116809,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PYRO,ATTRIBUTE_FIRE) then
		-- 创建「火之玉衍生物」的卡片数据
		local token=Duel.CreateToken(tp,98596597)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤因对方效果从自己的手牌或场上送去自己墓地的怪兽
function c98596596.cfilter2(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsLocation(LOCATION_GRAVE)
		and c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 效果②的发动条件：自己的手卡·场上的怪兽被对方的效果送去墓地，且这张卡已在魔陷区表侧表示存在
function c98596596.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c98596596.cfilter2,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果②的靶向函数：检查怪兽区域空位以及是否能特殊召唤衍生物，计算送去墓地的怪兽数量，并设置操作信息
function c98596596.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤特定属性和数值的「火之玉衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,23116809,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PYRO,ATTRIBUTE_FIRE) end
	local ct=eg:FilterCount(c98596596.cfilter2,nil,tp)
	e:SetLabel(ct)
	-- 取可用怪兽区域空位数和送去墓地的怪兽数量的较小值，作为预计特殊召唤的衍生物数量
	ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),ct)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 设置连锁的操作信息：特殊召唤对应数量的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设置连锁的操作信息：特殊召唤对应数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 效果②的效果处理：把最多有那些怪兽数量的「火之玉衍生物」尽可能在自己场上特殊召唤
function c98596596.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可用的怪兽区域空位数与送去墓地的怪兽数量的较小值，确定本次特殊召唤的实际数量
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),e:GetLabel())
	if not e:GetHandler():IsRelateToEffect(e) or ct<=0
		-- 或者如果玩家当前不能特殊召唤「火之玉衍生物」，则不处理效果
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,23116809,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PYRO,ATTRIBUTE_FIRE) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	for i=1,ct do
		-- 循环创建「火之玉衍生物」的卡片数据
		local token=Duel.CreateToken(tp,98596597)
		-- 逐步将衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end

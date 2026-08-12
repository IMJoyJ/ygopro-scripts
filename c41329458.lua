--幻獣機グリーフィン
-- 效果：
-- 自己的主要阶段时，把自己场上2只名字带有「幻兽机」的怪兽解放才能发动。这张卡从手卡特殊召唤。「幻兽机 加里宁狮鹫」的这个效果1回合只能使用1次。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把手卡1只名字带有「幻兽机」的怪兽丢弃才能发动。把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
function c41329458.initial_effect(c)
	-- 自己主要阶段时，把场上2只名字带有「幻兽机」的怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41329458,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,41329458)
	e1:SetCost(c41329458.spcost)
	e1:SetTarget(c41329458.sptg)
	e1:SetOperation(c41329458.spop)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 判断场上是否存在衍生物
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 1回合1次，把手卡1只名字带有「幻兽机」的怪兽丢弃才能发动。把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41329458,1))  --"特召衍生物"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c41329458.spcost2)
	e4:SetTarget(c41329458.sptg2)
	e4:SetOperation(c41329458.spop2)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选场上或手卡中名字带有「幻兽机」的怪兽
function c41329458.rfilter(c,tp)
	return c:IsSetCard(0x101b) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否满足解放2只「幻兽机」怪兽的条件，并选择要解放的怪兽组
function c41329458.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的「幻兽机」怪兽组
	local rg=Duel.GetReleaseGroup(tp):Filter(c41329458.rfilter,nil,tp)
	-- 检查是否可以选出2只满足条件的怪兽进行解放
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的2只怪兽作为解放对象
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 使用代替解放次数的函数
	aux.UseExtraReleaseCount(g,tp)
	-- 实际执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤的条件
function c41329458.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c41329458.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于筛选手卡中名字带有「幻兽机」且可丢弃的怪兽
function c41329458.cfilter(c)
	return c:IsSetCard(0x101b) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 检查是否满足丢弃1只「幻兽机」怪兽的条件，并执行丢弃操作
function c41329458.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只名字带有「幻兽机」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41329458.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1只名字带有「幻兽机」的怪兽
	Duel.DiscardHand(tp,c41329458.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置召唤衍生物的条件
function c41329458.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置召唤衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行召唤衍生物的操作
function c41329458.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建衍生物卡片
		local token=Duel.CreateToken(tp,41329459)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end

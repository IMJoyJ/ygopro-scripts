--ダイノルフィア・レクスターム
-- 效果：
-- 「恐啡肽狂龙」融合怪兽＋「恐啡肽狂龙」怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：持有自己基本分数值以上的攻击力的对方场上的怪兽不能把效果发动。
-- ②：自己·对方回合，把基本分支付一半才能发动。对方场上的全部怪兽的攻击力直到回合结束时变成和自己基本分数值相同。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只6星以下的「恐啡肽狂龙」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册卡片的融合召唤手续、①效果（永续效果，限制对方怪兽效果发动）、②效果（二速，支付一半基本分使对方怪兽攻击力变为与自己基本分相同）、③效果（被破坏时从墓地特殊召唤6星以下「恐啡肽狂龙」怪兽）
function c92798873.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤素材为1只「恐啡肽狂龙」融合怪兽和1只「恐啡肽狂龙」怪兽
	aux.AddFusionProcFun2(c,c92798873.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x173),true)
	-- ①：持有自己基本分数值以上的攻击力的对方场上的怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c92798873.actfilter)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把基本分支付一半才能发动。对方场上的全部怪兽的攻击力直到回合结束时变成和自己基本分数值相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92798873,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_CHAIN_END+TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1,92798873)
	-- 设置效果发动条件为不在伤害计算后
	e2:SetCondition(aux.dscon)
	e2:SetCost(c92798873.atkcost)
	e2:SetTarget(c92798873.atktg)
	e2:SetOperation(c92798873.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只6星以下的「恐啡肽狂龙」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92798873,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,92798873+o)
	e3:SetCondition(c92798873.spcon)
	e3:SetTarget(c92798873.sptg)
	e3:SetOperation(c92798873.spop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数：必须是「恐啡肽狂龙」融合怪兽
function c92798873.matfilter(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x173)
end
-- 限制发动效果的怪兽过滤函数：对方场上攻击力在自己当前基本分数值以上的怪兽
function c92798873.actfilter(e,c)
	-- 判断怪兽的攻击力是否大于或等于自己当前的基本分
	return c:IsAttackAbove(Duel.GetLP(e:GetHandlerPlayer()))
end
-- ②效果的发动代价（Cost）函数：支付一半的基本分
function c92798873.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 玩家支付当前基本分一半（向下取整）的数值
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 攻击力变更效果的目标过滤函数：对方场上表侧表示且攻击力不等于指定基本分数值的怪兽
function c92798873.atkfilter(c,lp)
	return c:IsFaceup() and c:GetAttack()~=lp
end
-- ②效果的发动准备（Target）函数：检查对方场上是否存在攻击力不等于“支付Cost后的基本分”的表侧表示怪兽
function c92798873.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算预计需要支付的基本分数值（当前基本分的一半）
		local cost=math.floor(Duel.GetLP(tp)/2)
		-- 获取影响玩家支付基本分Cost的卡片效果列表（如「恐啡肽狂龙」反击陷阱的代替支付效果）
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_LPCOST_CHANGE)}
		for _,te in ipairs(ce) do
			local con=te:GetCondition()
			local val=te:GetValue()
			if (not con or con(te)) then
				cost=val(te,e,tp,cost)
			end
		end
		-- 检查对方场上是否存在至少1只攻击力不等于“支付Cost后剩余基本分”的表侧表示怪兽
		return Duel.IsExistingMatchingCard(c92798873.atkfilter,tp,0,LOCATION_MZONE,1,nil,Duel.GetLP(tp)-cost)
	end
end
-- ②效果的效果处理（Operation）函数：将对方场上所有表侧表示怪兽的攻击力直到回合结束时变成和自己当前基本分数值相同
function c92798873.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家当前的基本分数值
	local lp=Duel.GetLP(tp)
	-- 获取对方场上所有攻击力不等于当前基本分的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c92798873.atkfilter,tp,0,LOCATION_MZONE,nil,nil)
	local tc=g:GetFirst()
	-- 遍历符合条件的怪兽卡片组
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽的攻击力直到回合结束时变成和自己基本分数值相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件函数：这张卡被战斗或效果破坏
function c92798873.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤的目标过滤函数：墓地中6星以下的「恐啡肽狂龙」怪兽
function c92798873.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动准备（Target）函数：检查自己场上是否有空怪兽位，且墓地中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c92798873.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判断自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只可以特殊召唤的6星以下「恐啡肽狂龙」怪兽
		and Duel.IsExistingMatchingCard(c92798873.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果的效果处理（Operation）函数：从自己墓地选择1只6星以下的「恐啡肽狂龙」怪兽特殊召唤
function c92798873.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「恐啡肽狂龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c92798873.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

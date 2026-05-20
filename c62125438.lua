--シンクロン・キャリアー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「同调士」怪兽召唤。
-- ②：这张卡在怪兽区域存在，其他的「同调士」怪兽作为战士族·机械族同调怪兽的同调素材送去自己墓地的场合才能发动。在自己场上把1只「同调士衍生物」（机械族·地·2星·攻1000/守0）特殊召唤。
function c62125438.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「同调士」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62125438,0))  --"使用「同调士运送者」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置增加召唤次数效果的对象为「同调士」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1017))
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在，其他的「同调士」怪兽作为战士族·机械族同调怪兽的同调素材送去自己墓地的场合才能发动。在自己场上把1只「同调士衍生物」（机械族·地·2星·攻1000/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,62125438)
	e2:SetCondition(c62125438.spcon)
	e2:SetTarget(c62125438.sptg)
	e2:SetOperation(c62125438.spop)
	c:RegisterEffect(e2)
end
-- 过滤送去自己墓地的、属于自己且是怪兽卡的「同调士」卡片
function c62125438.filter(c,tp)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
-- 检查是否有「同调士」怪兽作为战士族或机械族同调怪兽的同调素材送去自己墓地
function c62125438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62125438.filter,1,nil,tp) and r==REASON_SYNCHRO and re:GetHandler():IsRace(RACE_WARRIOR+RACE_MACHINE)
end
-- 效果2的发动准备，检查怪兽区域空位以及是否能特殊召唤衍生物
function c62125438.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤特定的「同调士衍生物」（机械族·地·2星·攻1000/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,62125439,0x1017,TYPES_TOKEN_MONSTER,1000,0,2,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示该效果包含产生1只衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示该效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果2的处理，在满足特招条件时，在自己场上特殊召唤1只「同调士衍生物」
function c62125438.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或者如果无法特殊召唤该衍生物，则终止效果处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,62125439,0x1017,TYPES_TOKEN_MONSTER,1000,0,2,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	-- 创建卡号为62125439的「同调士衍生物」卡片
	local token=Duel.CreateToken(tp,62125439)
	-- 将创建的衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

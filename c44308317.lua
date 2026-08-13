--氷結界の依巫
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要自己场上有其他的「冰结界」怪兽存在，对方场上的守备表示怪兽不能把表示形式变更。
-- ③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外才能发动。在自己场上把1只「冰结界衍生物」（水族·水·1星·攻/守0）特殊召唤。
function c44308317.initial_effect(c)
	-- ②：只要自己场上有其他的「冰结界」怪兽存在，对方场上的守备表示怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c44308317.postg)
	e1:SetCondition(c44308317.poscon)
	c:RegisterEffect(e1)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44308317,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,44308317)
	e2:SetCondition(c44308317.spcon)
	e2:SetTarget(c44308317.sptg)
	e2:SetOperation(c44308317.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外才能发动。在自己场上把1只「冰结界衍生物」（水族·水·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44308317,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,44308318)
	-- 设置③效果的发动代价：将位于墓地的这张卡除外（aux.bfgcost 实现）。
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c44308317.tkcon)
	e3:SetTarget(c44308317.tktg)
	e3:SetOperation(c44308317.tkop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片为表侧表示且持有「冰结界」字段（0x2f）。
function c44308317.posfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ②效果的适用条件：自己场上存在除自身以外的表侧表示「冰结界」怪兽。
function c44308317.poscon(e)
	-- 检查自己场上（LOCATION_MZONE）是否存在1只以上满足 posfilter 的冰结界怪兽，且排除效果持有者自身。
	return Duel.IsExistingMatchingCard(c44308317.posfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- ②效果的影响对象限定：只对守备表示怪兽生效（不能变更表示形式）。
function c44308317.postg(e,c)
	return c:IsDefensePos()
end
-- 过滤函数：判断卡片为表侧表示且持有「冰结界」字段（0x2f）。
function c44308317.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ①效果的发动条件：自己场上有表侧表示的「冰结界」怪兽存在。
function c44308317.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只以上满足 cfilter 的冰结界怪兽。
	return Duel.IsExistingMatchingCard(c44308317.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动合法性判定：自己场上有空余的怪兽区，且手卡的这张卡可以特殊召唤；满足则设置特殊召唤操作信息。
function c44308317.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否有空余的怪兽区域可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将要把这张卡本身特殊召唤，数量为1（对象确定，用于连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联（未离场），将其以表侧表示特殊召唤到自己场上。
function c44308317.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件/苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：判断卡片为表侧表示且持有「冰结界」字段（0x2f）。
function c44308317.tkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ③效果的发动条件：自己场上有表侧表示的「冰结界」怪兽存在。
function c44308317.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只以上满足 tkfilter 的冰结界怪兽。
	return Duel.IsExistingMatchingCard(c44308317.tkfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③效果发动合法性判定：自己场上有空余的怪兽区，且玩家可以特殊召唤「冰结界衍生物」（水族·水·1星·攻/守0）。
function c44308317.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否有空余的怪兽区域可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家能否特殊召唤「冰结界衍生物」（水族·水·1星·攻/守0）到自己场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44308318,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置操作信息：本次处理将产生1只衍生物（对象未确定，因此 targets 为 nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理包含1只怪兽的特殊召唤，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ③效果处理：若场上仍有空位且玩家仍可特殊召唤衍生物，则生成1只「冰结界衍生物」并特殊召唤到自己场上。
function c44308317.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：如果自己场上没有空余的怪兽区域，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认：当前玩家仍能特殊召唤「冰结界衍生物」（水族·水·1星·攻/守0）。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,44308318,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		-- 创建1只由我方控制的「冰结界衍生物」（卡号44308318）。
		local token=Duel.CreateToken(tp,44308318)
		-- 将衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end

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
	-- ①：自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外才能发动。在自己场上把1只「冰结界衍生物」（水族·水·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44308317,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,44308318)
	-- 将这张卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c44308317.tkcon)
	e3:SetTarget(c44308317.tktg)
	e3:SetOperation(c44308317.tkop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否存在正面表示的「冰结界」怪兽
function c44308317.posfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果条件函数：判断自己场上是否存在「冰结界」怪兽
function c44308317.poscon(e)
	-- 检查以自己为玩家，在场上是否存在至少1张正面表示的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c44308317.posfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果目标函数：判断目标怪兽是否为守备表示
function c44308317.postg(e,c)
	return c:IsDefensePos()
end
-- 过滤函数：检查场上是否存在正面表示的「冰结界」怪兽
function c44308317.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果条件函数：判断自己场上是否存在「冰结界」怪兽
function c44308317.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为玩家，在场上是否存在至少1张正面表示的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c44308317.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数：判断是否可以将此卡特殊召唤
function c44308317.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将此卡特殊召唤
function c44308317.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：检查场上是否存在正面表示的「冰结界」怪兽
function c44308317.tkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果条件函数：判断自己场上是否存在「冰结界」怪兽
function c44308317.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为玩家，在场上是否存在至少1张正面表示的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c44308317.tkfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数：判断是否可以特殊召唤衍生物
function c44308317.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44308318,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置连锁操作信息：将衍生物特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：将衍生物特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理函数：将衍生物特殊召唤
function c44308317.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断自己是否可以特殊召唤衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,44308318,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		-- 创造一张「冰结界衍生物」
		local token=Duel.CreateToken(tp,44308318)
		-- 将衍生物以正面表示特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end

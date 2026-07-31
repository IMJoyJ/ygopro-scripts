--多次元壊獣ラディアン
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。在自己场上把1只「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）特殊召唤。这衍生物不能作为同调素材。
function c28674152.initial_effect(c)
	-- 设置该卡在场上只能存在一张，并且过滤条件是同属性的卡。
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c28674152.spcon)
	e1:SetTarget(c28674152.sptg)
	e1:SetOperation(c28674152.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c28674152.spcon2)
	c:RegisterEffect(e2)
	-- ④：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。在自己场上把1只「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）特殊召唤。这衍生物不能作为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28674152,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c28674152.tkcost)
	e3:SetTarget(c28674152.tktg)
	e3:SetOperation(c28674152.tkop)
	c:RegisterEffect(e3)
end
c28674152.mentioned_counter={
	[0x37]=true,
}
-- 定义一个过滤函数，用于判断怪兽是否可以被解放以及对方怪兽区是否有空位。
function c28674152.spfilter(c,tp)
	-- 该行代码是spfilter函数的实现，返回怪兽是否可释放且对方怪兽区有空位。
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 定义特殊召唤的条件，如果存在满足spfilter过滤条件的卡片则返回true
function c28674152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 该行代码是spcon函数的实现，判断是否存在满足spfilter函数条件的怪兽。
	return Duel.IsExistingMatchingCard(c28674152.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 设置特殊召唤的目标和操作，并选择要解放的怪兽。
function c28674152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足spfilter过滤条件的卡片组。
	local g=Duel.GetMatchingGroup(c28674152.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤的操作，释放选定的怪兽。
function c28674152.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 释放目标怪兽。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义一个过滤函数，用于判断怪兽是否为表侧表示且属于特定卡组。
function c28674152.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 定义第二个特殊召唤的条件，如果对方场上有表侧表示的「坏兽」怪兽则返回true
function c28674152.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家的怪兽区是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在满足cfilter过滤条件的卡片。
		and Duel.IsExistingMatchingCard(c28674152.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义衍生物特殊召唤的费用，移除2个坏兽指示物。
function c28674152.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除坏兽指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 移除坏兽指示物。
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 定义衍生物特殊召唤的目标和条件。
function c28674152.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定卡号的token。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息为token效果。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义衍生物特殊召唤的操作，如果怪兽区已满或无法特殊召唤则返回。
function c28674152.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的怪兽区是否为空。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否可以特殊召唤指定卡号的token。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建衍生物Token。
	local token=Duel.CreateToken(tp,28674153)
	-- 特殊召唤衍生物Token。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 设置衍生物不能作为同调素材的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1)
	token:RegisterEffect(e1,true)
end

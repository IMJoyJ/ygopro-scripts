--多次元壊獣ラディアン
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。在自己场上把1只「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）特殊召唤。这衍生物不能作为同调素材。
function c28674152.initial_effect(c)
	-- 设置此卡在场上只能存在1只，且必须是恶魔族·坏兽卡组的怪兽
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
-- 过滤满足条件的怪兽：可以被解放用于特殊召唤且对方场上存在可用怪兽区
function c28674152.spfilter(c,tp)
	-- 满足条件：可以被解放用于特殊召唤且对方场上存在可用怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断特殊召唤条件是否满足：检查对方场上是否存在可解放的怪兽
function c28674152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在可解放的怪兽
	return Duel.IsExistingMatchingCard(c28674152.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 设置特殊召唤目标：选择对方场上的1只怪兽进行解放
function c28674152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组：获取对方场上的所有可解放怪兽
	local g=Duel.GetMatchingGroup(c28674152.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作：将选中的怪兽解放
function c28674152.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽解放用于特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤满足条件的怪兽：场上表侧表示且属于坏兽卡组
function c28674152.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 判断特殊召唤条件是否满足：检查己方场上是否存在坏兽怪兽且己方有可用怪兽区
function c28674152.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方是否有可用怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在坏兽怪兽
		and Duel.IsExistingMatchingCard(c28674152.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 设置衍生物效果的发动费用：移除自己和对方场上的2个坏兽指示物
function c28674152.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个坏兽指示物作为发动费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 移除自己和对方场上的2个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 设置衍生物效果的目标：检查己方是否有可用怪兽区且可以特殊召唤衍生物
function c28674152.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方是否有可用怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：衍生物效果将特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：衍生物效果将特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行衍生物效果：检查是否可以特殊召唤衍生物
function c28674152.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建拉迪安衍生物
	local token=Duel.CreateToken(tp,28674153)
	-- 将拉迪安衍生物特殊召唤到己方场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 设置衍生物效果：衍生物不能作为同调素材
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1)
	token:RegisterEffect(e1,true)
end

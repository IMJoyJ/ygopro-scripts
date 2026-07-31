--多次元壊獣ラディアン
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。在自己场上把1只「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）特殊召唤。这衍生物不能作为同调素材。
function c28674152.initial_effect(c)
	-- 设置此卡在场上的唯一性，确保同一时间场上只能存在1只属于「坏兽」的怪兽
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
-- 定义用于判断是否可以解放的过滤函数，检查目标怪兽是否可被解放并满足特殊召唤条件
function c28674152.spfilter(c,tp)
	-- 返回目标怪兽是否可被解放且对方场上存在可用区域
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 定义特殊召唤条件函数，检查是否存在满足条件的怪兽可用于解放
function c28674152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回是否存在满足条件的怪兽可用于解放
	return Duel.IsExistingMatchingCard(c28674152.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 定义特殊召唤目标选择函数，用于选择要解放的怪兽
function c28674152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的怪兽组合作为可选对象
	local g=Duel.GetMatchingGroup(c28674152.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤操作函数，执行实际的解放动作
function c28674152.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定目标怪兽以特殊召唤原因为由进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义用于判断对方场上是否存在「坏兽」怪兽的过滤函数
function c28674152.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 定义第二条特殊召唤条件函数，检查己方是否有空怪兽区且对方场上有「坏兽」怪兽
function c28674152.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回己方场上是否存在可用怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 返回对方场上是否存在「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c28674152.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义衍生物效果的费用支付函数，移除自己和对方场上的2个坏兽指示物
function c28674152.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除指定数量的坏兽指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 实际移除指定数量的坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 定义衍生物效果的目标选择函数，检查是否满足特殊召唤条件
function c28674152.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 返回己方场上是否存在可用怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 返回玩家是否可以特殊召唤指定编号的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：将要特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义衍生物效果的操作函数，检查是否满足召唤条件并执行召唤
function c28674152.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 返回己方场上是否存在可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 返回玩家是否可以特殊召唤指定编号的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建编号为28674153的拉迪安衍生物
	local token=Duel.CreateToken(tp,28674153)
	-- 将创建好的衍生物以攻击表示形式特殊召唤到己方场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 给衍生物添加效果，使其不能作为同调素材
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1)
	token:RegisterEffect(e1,true)
end

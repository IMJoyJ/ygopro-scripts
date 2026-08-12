--多次元壊獣ラディアン
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。在自己场上把1只「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）特殊召唤。这衍生物不能作为同调素材。
function c28674152.initial_effect(c)
	-- 设置场上唯一性规则：自己怪兽区域只能有1只表侧表示的「坏兽」怪兽存在
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
	-- ④：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。在自己场上把1只「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）特殊召唤。
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
-- 过滤函数：筛选对方场上可以解放且解放后自己场上仍有可用怪兽区域的怪兽
function c28674152.spfilter(c,tp)
	-- 该怪兽可以作为特殊召唤的解放对象，且将其解放后对方场上有空余怪兽区可供这张卡特召
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 特殊召唤条件函数：检查对方场上是否存在满足解放条件的怪兽
function c28674152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只可以解放且解放后有空位的怪兽
	return Duel.IsExistingMatchingCard(c28674152.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤目标函数：从对方场上选择1只要解放的怪兽
function c28674152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得对方场上所有满足解放条件的怪兽组
	local g=Duel.GetMatchingGroup(c28674152.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 向玩家发送「请选择要解放的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理函数：将之前选定的对方怪兽解放
function c28674152.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因将选定的对方场上怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数：筛选表侧表示的「坏兽」怪兽
function c28674152.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤条件函数：确认自己场上有空位且对方场上有「坏兽」怪兽存在
function c28674152.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的怪兽区域是否有可用空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查对方场上是否存在至少1只表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c28674152.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 代价函数：检查并把自己·对方场上2个坏兽指示物取除作为发动代价
function c28674152.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认能否从双方场上取除2个坏兽指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 从双方场上取除2个坏兽指示物作为代价
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 目标函数：确认自己场上有空位且可以特殊召唤「拉迪安衍生物」
function c28674152.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的怪兽区域是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己是否可以特殊召唤「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：此效果将生成1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：此效果将进行1次特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理函数：再次确认自己场上有空位且可以特殊召唤衍生物，否则中断处理
function c28674152.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的怪兽区域没有可用空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或无法特殊召唤「拉迪安衍生物」（恶魔族·暗·7星·攻2800/守0），则不进行处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,28674153,0,TYPES_TOKEN_MONSTER,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 在自己场上生成1只「拉迪安衍生物」
	local token=Duel.CreateToken(tp,28674153)
	-- 将该衍生物在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能作为同调素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1)
	token:RegisterEffect(e1,true)
end

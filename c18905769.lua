--ギーブル
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升自己场上的龙族怪兽数量×400。
-- ②：这张卡战斗破坏怪兽时才能发动。在自己场上把1只「翼龙衍生物」（龙族·光·1星·攻/守400）特殊召唤。
-- ③：自己·对方的战斗阶段以及主要阶段2才能发动。表侧表示进行1只龙族怪兽的上级召唤。
local s,id,o=GetID()
-- 初始化卡片效果的函数，注册了提升攻击力的永续效果、战斗破坏怪兽时特殊召唤衍生物的诱发效果以及在战斗阶段和主要阶段2召唤龙族怪兽的诱发即时效果。
function s.initial_effect(c)
	-- ①：这张卡的攻击力上升自己场上的龙族怪兽数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽时才能发动。在自己场上把1只「翼龙衍生物」（龙族·光·1星·攻/守400）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为自己怪兽战斗破坏对方怪兽。
	e2:SetCondition(aux.bdcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段以及主要阶段2才能发动。表侧表示进行1只龙族怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_BATTLE_START+TIMING_BATTLE_END+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.sucon)
	e3:SetTarget(s.sutg)
	e3:SetOperation(s.suop)
	c:RegisterEffect(e3)
end
-- 计算自身攻击力上升数值的辅助函数，统计自己场上表侧表示的龙族怪兽数量乘以400。
function s.atkval(e,c)
	-- 返回自己场上表侧表示龙族怪兽数量乘以400后的数值。
	return Duel.GetMatchingGroupCount(aux.AND(Card.IsRace,Card.IsFaceup),c:GetControler(),LOCATION_MZONE,0,nil,RACE_DRAGON)*400
end
-- 特殊召唤衍生物效果的发动准备与合法性检查函数，确认怪兽区域是否有空格且玩家是否可以特殊召唤该衍生物怪兽。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空闲的主要怪兽区域供衍生物特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤出特定攻防、等级、属性和种族的衍生物怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_DRAGON,ATTRIBUTE_LIGHT) end
	-- 设置效果处理的操作信息，表明本效果包含在主要怪兽区域特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end
-- 特殊召唤衍生物效果的执行处理函数，在效果处理时再次检查场地空位和特招合法性，创建并特殊召唤衍生物。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时进行检查，如果没有可用的主要怪兽区域则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 在效果处理时检查是否能够特殊召唤该衍生物怪兽，如果不能则不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_DRAGON,ATTRIBUTE_LIGHT) then return end
	-- 在内存中生成一张用于召唤的特定卡片ID的衍生物卡片对象。
	local token=Duel.CreateToken(tp,id+o)
	-- 将生成的衍生物卡片以表侧表示特殊召唤到发动玩家的场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断上级召唤效果是否可以发动的条件函数，检查当前是否是双方的战斗阶段或者主要阶段2。
function s.sucon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏正在进行的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_BATTLE or ph==PHASE_MAIN2
end
-- 过滤函数，筛选出满足上级召唤条件且是龙族的手牌怪兽。
function s.sufilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsSummonable(true,nil,1)
end
-- 上级召唤效果的发动准备与检查函数，确认手牌中是否存在可召唤的龙族怪兽，并声明包含召唤操作的操作信息。
function s.sutg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前判断手牌中是否存在至少1张符合筛选条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sufilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理的操作信息，表明本效果包含从手牌通常召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 上级召唤效果的执行处理函数，让玩家从手牌中选择符合条件的龙族怪兽进行通常召唤。
function s.suop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示消息，指示其选择要召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌中选择1张符合筛选条件的龙族怪兽卡片。
	local g=Duel.SelectMatchingCard(tp,s.sufilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家无视每回合的通常召唤次数限制，对所选怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end

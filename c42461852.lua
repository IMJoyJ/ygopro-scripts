--サイバネット・ストーム
-- 效果：
-- ①：场上的连接状态的怪兽的攻击力·守备力上升500。
-- ②：只要这张卡在场地区域存在，连接怪兽的连接召唤不会被无效化。
-- ③：自己受到2000以上的战斗·效果伤害的场合才能发动。只把自己的额外卡组的里侧表示的卡洗切，那张最上面的卡翻开。翻开的卡是电子界族连接怪兽的场合，那只怪兽特殊召唤。不是的场合回到原状。
function c42461852.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的连接状态的怪兽的攻击力·守备力上升500。（此段实现攻击力上升部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 筛选出场上处于连接状态的怪兽，作为攻击力上升效果的适用对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLinkState))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，连接怪兽的连接召唤不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	-- 指定适用对象为连接召唤的怪兽（以连接召唤方式登场的怪兽），使其连接召唤不会被无效化。
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSummonType,SUMMON_TYPE_LINK))
	c:RegisterEffect(e4)
	-- ③：自己受到2000以上的战斗·效果伤害的场合才能发动。只把自己的额外卡组的里侧表示的卡洗切，那张最上面的卡翻开。翻开的卡是电子界族连接怪兽的场合，那只怪兽特殊召唤。不是的场合回到原状。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42461852,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(c42461852.spcon)
	e5:SetTarget(c42461852.sptg)
	e5:SetOperation(c42461852.spop)
	c:RegisterEffect(e5)
end
-- 触发条件：伤害承受方是自己（ep==tp）且伤害数值至少为2000。
function c42461852.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=2000
end
-- 效果发动时的合法性检查：确保额外卡组有里侧表示卡、自己可进行特殊召唤、且额外卡组怪兽可用的特殊召唤区域有空位。
function c42461852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1张里侧表示的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查自己当前是否处于可以进行特殊召唤的状态。
		and Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查自己场上是否有可用的额外卡组怪兽特殊召唤区域，以容纳从额外卡组特殊召唤的连接怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)>0 end
	-- 把本次效果处理的信息登记为：从额外卡组特殊召唤1只怪兽，用于连锁处理和相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时的入口检查：若自己不能特殊召唤或额外卡组已没有里侧表示的卡，则中止处理。
function c42461852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己已经不能特殊召唤，则不执行后续洗切/翻开/特殊召唤。
	if not Duel.IsPlayerCanSpecialSummon(tp)
		-- 若自己额外卡组里侧表示的卡数量为0，则没有可洗切翻开的卡，效果不处理。
		or Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)==0 then return end
	-- 将自己额外卡组的所有里侧表示卡进行洗切，使最上方的卡随机化。
	Duel.ShuffleExtra(tp)
	-- 确认并展示自己额外卡组最上方的1张卡，用于判定是否为电子界族连接怪兽。
	Duel.ConfirmExtratop(tp,1)
	-- 取得额外卡组最上方的那张卡存入变量tc，供后续判断。
	local tc=Duel.GetExtraTopGroup(tp,1):GetFirst()
	if tc:IsType(TYPE_LINK) and tc:IsRace(RACE_CYBERSE) then
		-- 将满足条件的电子界族连接怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

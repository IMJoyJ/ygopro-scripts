--宝玉の玲瓏
-- 效果：
-- ①：「宝玉的玲珑」在自己场上只能有1张表侧表示存在。
-- ②：自己场上的「宝玉兽」怪兽的攻击力上升那原本守备力数值。
-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动（伤害步骤也能发动）。从自己的手卡·墓地选1只「宝玉兽」怪兽特殊召唤。这个回合，自己受到的全部伤害变成一半。
local s,id,o=GetID()
-- 注册「宝玉的玲珑」的整卡效果：①用SetUniqueOnField设置此卡在自己场上只能有1张表侧表示；②e1为魔法卡发动效果，允许在伤害步骤发动；③e2为永续效果，使自己场上的「宝玉兽」怪兽攻击力上升其原本守备力；④e3为诱发即时效果，在自己魔陷区有「宝玉兽」卡被放置时，送墓自身发动，从手卡·墓地特召1只「宝玉兽」且本回合自己受到伤害减半。
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- （伤害步骤也能发动）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 伤害步骤限制：仅在非伤害步骤、或伤害计算前可以发动，保证伤害步骤内不能在伤害计算后发动（e1本身带DAMAGE_STEP）。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- 自己场上的「宝玉兽」怪兽的攻击力上升那原本守备力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置e2的适用对象：自己怪兽区域中属于「宝玉兽」系列的怪兽（以0x1034系列字段判断）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	-- 设定攻击力上升的数值为每只适用怪兽的原本守备力数值。
	e2:SetValue(aux.TargetBoolFunction(Card.GetBaseDefense))
	c:RegisterEffect(e2)
	-- 自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动（伤害步骤也能发动）。从自己的手卡·墓地选1只「宝玉兽」怪兽特殊召唤。这个回合，自己受到的全部伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.con)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
-- 触发过滤函数：判断移动/放置后的卡是否为表侧表示、属「宝玉兽」系列、由tp控制、且位于魔法与陷阱区域的主区域（GetSequence()<5排除场地魔法区域），从而识别“自己的魔法与陷阱区域有「宝玉兽」卡被放置”的情况。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- 效果发动条件：事件源eg中存在至少1张满足s.cfilter的卡，即刚刚有「宝玉兽」卡被放置到自己魔法与陷阱区域。
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 代价判定：这张「宝玉的玲珑」已处于效果有效状态（STATUS_EFFECT_ENABLED）且可作为代价送去墓地时，合法发动；之后执行送墓代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsStatus(STATUS_EFFECT_ENABLED) and c:IsAbleToGraveAsCost() end
	-- 将这张表侧表示的「宝玉的玲珑」以代价（REASON_COST）送去墓地，满足③的送墓发动条件。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 特召对象过滤器：目标是「宝玉兽」怪兽，并且能够被tp玩家用效果e特殊召唤（同时检查召唤条件和苏生限制）。
function s.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性检查：自己主要怪兽区有空格，且手卡·墓地存在至少1只满足s.filter的「宝玉兽」怪兽（不取对象，处理时再选择）。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查tp的主要怪兽区是否有空位，若没有则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查tp的手卡·墓地是否存在至少1张符合条件的「宝玉兽」可特召怪兽（s.filter附带e、tp参数）。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本次操作属于特殊召唤（CATEGORY_SPECIAL_SUMMON），预定从手卡·墓地由tp特殊召唤1只怪兽，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：先给tp注册一个回合结束失效的伤害变更效果，使tp本回合受到的全部伤害减半；然后检查主要怪兽区空位，若有空位则从手卡·墓地选择1只「宝玉兽」并用表侧表示特殊召唤。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己的手卡·墓地选1只「宝玉兽」怪兽特殊召唤。这个回合，自己受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将伤害减半效果注册给tp，该效果以tp为目标，持续到本回合结束（RESET_PHASE+PHASE_END）。
	Duel.RegisterEffect(e1,tp)
	-- 如果主要怪兽区没有空位则无法特召，直接结束处理（伤害减半效果已经生效）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向tp显示选择提示‘请选择要特殊召唤的卡’（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从tp的手卡·墓地中筛选出符合条件的「宝玉兽」（用aux.NecroValleyFilter排除墓地效果被王家长眠之谷无效的卡），并让tp选择1张作为特召对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的「宝玉兽」怪兽以表侧表示特殊召唤到tp场上（不改变控制者，检查条件已由s.filter完成）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 伤害数值计算函数：将受到的伤害dam除以2（向下取整），实现伤害减半效果。
function s.val(e,re,dam)
	return dam//2
end

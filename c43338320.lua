--冥骸府－メメントラン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「莫忘」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：自己场上的怪兽被战斗·效果破坏的场合，以那之内的1只为对象才能发动。比那只怪兽等级低的1只「莫忘」怪兽从自己的手卡·墓地特殊召唤。
-- ③：自己结束阶段，以自己墓地1张「莫忘」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册场地魔法卡的通用发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「莫忘」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.lecon)
	-- 设置效果值为判断是否为魔法卡或陷阱卡的效果类型
	e2:SetValue(aux.TargetBoolFunction(Effect.IsHasType,EFFECT_TYPE_ACTIVATE))
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽被战斗·效果破坏的场合，以那之内的1只为对象才能发动。比那只怪兽等级低的1只「莫忘」怪兽从自己的手卡·墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段，以自己墓地1张「莫忘」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断目标卡是否为控制者为tp且为表侧表示的「莫忘」卡
function s.lfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 判断是否为「莫忘」怪兽参与战斗，用于触发①效果
function s.lecon(e)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前被攻击怪兽
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	return a and s.lfilter(a,tp) or d and s.lfilter(d,tp)
end
-- 过滤函数，判断目标怪兽是否为己方场上被破坏的怪兽且满足特殊召唤条件
function s.cfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and not c:IsType(TYPE_TOKEN)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsCanBeEffectTarget(e) and c:IsFaceupEx()
		-- 判断己方场上被破坏的怪兽等级是否大于等于2且存在满足条件的「莫忘」怪兽可特殊召唤
		and c:IsLevelAbove(2) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤函数，判断目标卡是否为「莫忘」怪兽且等级低于指定等级
function s.filter(c,e,tp,lv)
	return c:IsSetCard(0x1a1) and c:IsLevelBelow(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsPreviousControler(tp)
		and chkc:IsPreviousLocation(LOCATION_MZONE) and chkc:IsReason(REASON_BATTLE+REASON_EFFECT) end
	local g=eg:Filter(s.cfilter,nil,e,tp)
	-- 判断②效果是否可以发动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:Select(tp,1,1,nil)
	-- 设置当前连锁效果的目标卡
	Duel.SetTargetCard(sg)
	-- 设置②效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效且场上存在召唤空间
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「莫忘」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
	-- 执行特殊召唤操作
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的触发条件函数
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，判断目标卡是否为「莫忘」魔法或陷阱卡且可盖放
function s.sfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的目标选择函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	-- 判断③效果是否可以发动
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择墓地中的「莫忘」魔法或陷阱卡作为盖放对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置③效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的处理函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效且执行盖放操作
	if tc:IsRelateToEffect(e) then Duel.SSet(tp,tc) end
end

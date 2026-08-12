--ヴァリアンツV－ヴァイカント
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的灵摆区域放置。
function c41802073.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,41802073)
	e1:SetTarget(c41802073.sptg)
	e1:SetOperation(c41802073.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41802074)
	e2:SetCondition(c41802073.stcon)
	e2:SetTarget(c41802073.sttg)
	e2:SetOperation(c41802073.stop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,41802075)
	e3:SetCondition(c41802073.mvcon)
	e3:SetTarget(c41802073.mvtg)
	e3:SetOperation(c41802073.mvop)
	c:RegisterEffect(e3)
end
-- 判断是否可以将此卡特殊召唤到指定区域
function c41802073.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行灵摆效果的特殊召唤操作，并设置回合结束时不能特殊召唤非群豪怪兽的效果
function c41802073.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到指定区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 创建并注册一个回合结束时禁止特殊召唤非群豪怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41802073.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义禁止特殊召唤非群豪怪兽的效果目标函数
function c41802073.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 判断此卡是否为特殊召唤状态
function c41802073.stcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 定义筛选额外卡组中符合条件的群豪灵摆怪兽的过滤函数
function c41802073.stfilter(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
-- 判断是否可以发动怪兽效果①
function c41802073.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断额外卡组中是否存在符合条件的群豪灵摆怪兽
		and Duel.IsExistingMatchingCard(c41802073.stfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 执行怪兽效果①的操作，将额外卡组中的群豪灵摆怪兽放置到魔法与陷阱区域
function c41802073.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断魔法与陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到魔法与陷阱区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从额外卡组中选择符合条件的群豪灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c41802073.stfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽放置到魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽转换为永续魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 判断此卡是否从怪兽区域移动到其他区域
function c41802073.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 判断是否可以发动怪兽效果②
function c41802073.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 判断额外卡组中是否存在符合条件的群豪灵摆怪兽
		and Duel.IsExistingMatchingCard(c41802073.stfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 执行怪兽效果②的操作，将额外卡组中的群豪灵摆怪兽放置到灵摆区域
function c41802073.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断灵摆区域是否有空位
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置到灵摆区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从额外卡组中选择符合条件的群豪灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c41802073.stfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽放置到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--睨み統べるスネークアイズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的「蛇眼」怪兽的等级合计是2星以上的场合，可以从以下效果选择1个发动。
-- ●以对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ●以自己·对方场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
local s,id,o=GetID()
-- 定义卡片发动效果的初始化函数，设置卡片的发动条件、时点、限制以及效果分支处理
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的「蛇眼」怪兽的等级合计是2星以上的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且等级在1星以上的「蛇眼」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19c) and c:IsLevelAbove(1)
end
-- 检查自己场上的「蛇眼」怪兽的等级合计是否在2星以上
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上符合条件的「蛇眼」怪兽并计算其等级合计是否大于1（即2星以上）
	return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetLevel)>1
end
-- 过滤对方场上表侧表示或墓地中，且能放置到原本持有者魔陷区（有可用空格）的怪兽
function s.mfilter(c,tp,ft)
	if not (c:IsFaceupEx() and c:IsType(TYPE_MONSTER)) then return false end
	local p=c:GetOwner()
	if p~=tp then ft=0 end
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(p) then r=LOCATION_REASON_CONTROL end
	-- 检查原本持有者的魔陷区是否有足够的可用空格来放置该卡
	return Duel.GetLocationCount(p,LOCATION_SZONE,tp,r)>ft
end
-- 过滤场上原本是怪兽且当前当作永续魔法卡使用的卡，并确认其可以被特殊召唤
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查，处理取对象、效果分支选择、以及成为对象时的合法性判定
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(1-tp)
			and s.mfilter(chkc,tp,0)
		else return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	end
	local ft=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and 1 or 0
	-- 检查是否存在可以作为分支1（放置对方怪兽到魔陷区）合法对象的卡片
	local b1=Duel.IsExistingTarget(s.mfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp,ft)
	-- 检查自己场上是否有可用的怪兽区域空格（用于分支2的特殊召唤）
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以作为分支2（特殊召唤当作永续魔法的怪兽）合法对象的卡片
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})  --"放置怪兽/特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		-- 提示玩家选择要作为效果对象（放置到魔陷区）的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 优先从对方场上（其次从墓地）选择1只怪兽作为效果对象
		local g=aux.SelectTargetFromFieldFirst(tp,s.mfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择场上1张当作永续魔法卡使用的怪兽卡作为特殊召唤的对象
		local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
		-- 设置特殊召唤的操作信息，用于后续连锁处理和卡片效果检测
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理的入口函数，根据玩家在发动时选择的分支（Label值）执行对应的处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.mvop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.spop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 分支1的效果处理：将作为对象的怪兽移动到其原本持有者的魔陷区，并使其当作永续魔法卡使用
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将目标怪兽表侧表示移动到其原本持有者的魔法与陷阱区域
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 分支2的效果处理：将作为对象的、当作永续魔法卡使用的怪兽卡在自己场上特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选择为特殊召唤对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若目标卡片仍存在且符合效果，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

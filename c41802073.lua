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
	-- 为这张灵摆怪兽卡启用灵摆属性，使其可以作为灵摆卡在灵摆区发动、进行灵摆召唤，并注册灵摆卡的『卡的发动』效果。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,41802073)
	e1:SetTarget(c41802073.sptg)
	e1:SetOperation(c41802073.spop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】这个卡名的①②的怪兽效果1回合各能使用1次。①：这张卡是已特殊召唤的场合，自己主要阶段才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
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
-- 灵摆效果①的发动条件检测：根据这张卡在灵摆区的序列号算出正对面的主怪兽区域zone，确认这张卡可以被特殊召唤到该区域；满足后登记特殊召唤操作。
function c41802073.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 登记本次连锁的操作信息：将这张卡确定为特殊召唤对象，数量为1，供后续处理及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果①的处理：若这张卡仍与效果相关，将其特殊召唤到正对面的主怪兽区；随后给发动者附加直到回合结束时『不是「群豪」怪兽不能特殊召唤（从额外卡组特殊召唤除外）』的自肃效果。
function c41802073.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到指定zone（正对面的主要怪兽区域）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 灵摆效果①的自肃部分：『这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）』；以及怪兽效果①的『这张卡是已特殊召唤的场合，自己主要阶段才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41802073.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果注册给发动者tp，使其在直到回合结束的时间段内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定：若被特殊召唤的怪兽不是「群豪」且不是从额外卡组特殊召唤（即不在额外卡组），则禁止该特殊召唤；从额外卡组特殊召唤则不禁止。
function c41802073.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 怪兽效果①的发动条件：这张卡是以特殊召唤方式出场过的怪兽（满足『这张卡是已特殊召唤的场合』）。
function c41802073.stcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 选择过滤条件：从额外卡组中选出表侧表示、属于「群豪」、是灵摆怪兽且未被禁止的卡。
function c41802073.stfilter(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
-- 怪兽效果①发动条件检测：自己的魔法与陷阱区域存在空位，且额外卡组存在至少1张满足条件的「群豪」灵摆怪兽。
function c41802073.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己的魔法与陷阱区域有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认额外卡组中是否存在至少1张满足stfilter条件的「群豪」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c41802073.stfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 怪兽效果①的处理：从额外卡组选1只表侧表示的「群豪」灵摆怪兽，以表侧表示放置到自己的魔法与陷阱区域，并将其种类改为永续魔法卡。
function c41802073.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己的魔法与陷阱区域仍有空位，否则不进行后续处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 弹出选择提示，让发动者选择一张要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让发动者从自己的额外卡组选择1张符合条件的「群豪」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c41802073.stfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽卡以表侧表示移动到自己的魔法与陷阱区域（当作永续魔法卡放置）。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 对应效果原文『在自己的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置』，通过改变类型效果将这张卡变成永续魔法卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果②的触发条件：这张卡从原来的怪兽区域移动到了另一个怪兽区域（移动前后都在怪兽区，且位置或控制者发生变化）。
function c41802073.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 怪兽效果②的发动检测：自己的灵摆区域有可用空位，且额外卡组存在至少1张满足条件的「群豪」灵摆怪兽。
function c41802073.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域两个位置（0/1）中是否至少有一个可用空格。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 确认额外卡组中是否存在至少1张满足stfilter条件的「群豪」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c41802073.stfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 怪兽效果②的处理：从额外卡组选1只表侧表示的「群豪」灵摆怪兽，以表侧表示放置到自己的灵摆区域。
function c41802073.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己的灵摆区域仍有空位，否则不进行后续处理。
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 弹出选择提示，让发动者选择一张要放置到灵摆区的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让发动者从自己的额外卡组选择1张符合条件的「群豪」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c41802073.stfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽卡以表侧表示移动到自己的灵摆区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

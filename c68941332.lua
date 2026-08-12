--六花の薄氷
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只植物族怪兽解放来发动。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能把场上发动的效果发动。把怪兽解放来把这张卡发动的场合，再把那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽变成植物族。
function c68941332.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能把场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68941332,0))  --"不解放怪兽发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,68941332+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c68941332.target)
	e1:SetOperation(c68941332.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把自己场上1只植物族怪兽解放来发动。①：以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能把场上发动的效果发动。把怪兽解放来把这张卡发动的场合，再把那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽变成植物族。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68941332,1))  --"解放怪兽发动"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,68941332+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(c68941332.cost)
	e2:SetTarget(c68941332.target2)
	e2:SetOperation(c68941332.activate2)
	c:RegisterEffect(e2)
end
-- 过滤对方场上表侧表示的怪兽，且根据参数判定是否需要满足可以改变控制权的条件
function c68941332.filter(c,check)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT)
		and (check or c:IsAbleToChangeControler())
end
-- 不解放怪兽发动时的效果对象选择与判定函数
function c68941332.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c68941332.filter(chkc,true) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c68941332.filter,tp,0,LOCATION_MZONE,1,nil,true) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c68941332.filter,tp,0,LOCATION_MZONE,1,1,nil,true)
end
-- 不解放怪兽发动时的效果处理函数
function c68941332.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这张卡也能把自己场上1只植物族怪兽解放来发动。①：以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能把场上发动的效果发动。把怪兽解放来把这张卡发动的场合，再把那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽变成植物族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤解放发动的怪兽：需满足解放后有可用怪兽区域，且为自己场上的植物族怪兽（或受特定卡片效果影响可解放的对方怪兽），且对方场上有其他可作为对象的怪兽
function c68941332.rfilter(c,tp)
	-- 检查该怪兽解放后是否能空出可用的怪兽区域，且该怪兽由自己控制或是对方场上表侧表示的怪兽
	return Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
		-- 检查对方场上是否存在除被解放怪兽以外的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c68941332.filter,tp,0,LOCATION_MZONE,1,c)
end
-- 解放怪兽发动的Cost处理函数
function c68941332.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c68941332.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c68941332.rfilter,1,1,nil,tp)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 解放怪兽发动时的效果对象选择与判定函数
function c68941332.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c68941332.filter(chkc,false) end
	-- 检查是否为魔法卡发动，且对方场上是否存在可作为对象并能改变控制权的表侧表示怪兽
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(c68941332.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象（需满足可改变控制权条件）
	local g=Duel.SelectTarget(tp,c68941332.filter,tp,0,LOCATION_MZONE,1,1,nil,false)
	-- 设置连锁信息，该效果包含改变控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 解放怪兽发动时的效果处理函数
function c68941332.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，那只表侧表示怪兽不能把场上发动的效果发动。把怪兽解放来把这张卡发动的场合，再把那只怪兽的控制权直到结束阶段得到。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and tc:IsAbleToChangeControler() then
			-- 中断当前效果处理，使后续的控制权转移处理不与之前的效果视为同时处理
			Duel.BreakEffect()
			-- 尝试直到结束阶段得到该怪兽的控制权，若成功则执行后续处理
			if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
				-- 这个效果得到控制权的怪兽变成植物族。
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CHANGE_RACE)
				e2:SetValue(RACE_PLANT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end

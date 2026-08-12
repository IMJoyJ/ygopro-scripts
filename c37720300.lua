--スターシップ・アジャスト・プレーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上1只其他的机械族怪兽为对象才能发动。那只怪兽和这张卡的等级直到回合结束时变成那2只的等级合计的等级。这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册效果：等级变化
function s.initial_effect(c)
	-- ①：以自己场上1只其他的机械族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
-- 过滤器：对象怪兽必须表侧表示、等级高于1、种族为机械族
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsRace(RACE_MACHINE)
end
-- 效果处理：选择目标怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) and chkc~=c end
	-- 条件判断：确认自身等级高于1且场上存在符合条件的目标怪兽
	if chk==0 then return c:IsLevelAbove(1) and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标：选择1只符合条件的场上怪兽
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果处理：等级变化
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 那只怪兽和这张卡的等级直到回合结束时变成那2只的等级合计的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果：不能特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 限制：不能特殊召唤非机械族超量怪兽
function s.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end

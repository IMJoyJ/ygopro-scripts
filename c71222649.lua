--薄明の魔 レイラージュ
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的灵摆怪兽被对方的效果破坏的场合，可以作为那1只破坏的灵摆怪兽的代替而把这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只灵摆怪兽为对象才能发动。那只灵摆怪兽在自己的灵摆区域放置，这张卡特殊召唤。这个效果在灵摆区域放置的卡的灵摆效果在这个回合不能发动。
-- ②：自己·对方回合，把这张卡解放，以自己的灵摆区域1张卡为对象才能发动。这个回合，那张卡不会被对方的效果破坏。
local s,id,o=GetID()
-- 初始化函数，添加灵摆怪兽属性，并注册灵摆代替破坏效果、手牌特殊召唤放置效果以及解放自身赋予灵摆卡效果破坏抗性的效果
function s.initial_effect(c)
	-- 注册灵摆怪兽的基本属性和效果（灵摆召唤、灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的灵摆怪兽被对方的效果破坏的场合，可以作为那1只破坏的灵摆怪兽的代替而把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在的场合，以自己场上1只灵摆怪兽为对象才能发动。那只灵摆怪兽在自己的灵摆区域放置，这张卡特殊召唤。这个效果在灵摆区域放置的卡的灵摆效果在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，把这张卡解放，以自己的灵摆区域1张卡为对象才能发动。这个回合，那张卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"赋予抗性"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.indcost)
	e3:SetTarget(s.indtg)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
end
-- 代替破坏的卡片过滤函数：自己场上被对方效果破坏的灵摆怪兽
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp
end
-- 代替破坏效果的发动检测与处理函数
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable(e) and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否要发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(s.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 显示请选择要代替破坏的卡的系统提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 代替破坏值的过滤判定函数
function s.repval(e,c)
	return c==e:GetLabelObject()
end
-- 代替破坏的执行函数
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示此卡代替破坏效果发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 破坏作为代替的这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 效果①对象的过滤函数：自己场上的灵摆怪兽，且将其移动后怪兽区仍有空位
function s.pfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		-- 判断目标怪兽离开场上后是否能留出足够的怪兽区域空位用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动检测与目标选择函数
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.pfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为对象的灵摆怪兽
	if chk==0 then return Duel.IsExistingTarget(s.pfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查自己场上的灵摆区域是否有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 显示请选择效果的对象的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的1只灵摆怪兽作为对象
	local g=Duel.SelectTarget(tp,s.pfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置当前处理的操作信息为：特殊召唤手牌中的此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理执行函数
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选定的灵摆怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 将目标灵摆怪兽放置到自己的灵摆区域
		and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		-- 这个效果在灵摆区域放置的卡的灵摆效果在这个回合不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToChain() then
			-- 将手牌中的这张卡特殊召唤到场上
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的Cost检测与解放自身处理函数
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放场上的这张卡
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 赋予抗性对象的过滤条件判定函数：自己灵摆区域表侧表示的卡
function s.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 效果②的发动准备与目标检测选择函数
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.indfilter(chkc) end
	-- 检查自己的灵摆区域是否存在可以作为抗性赋予对象的卡
	if chk==0 then return Duel.IsExistingTarget(s.indfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 显示请选择表侧表示的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己灵摆区域的1张卡作为赋予抗性的对象
	Duel.SelectTarget(tp,s.indfilter,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 效果②的效果处理执行函数
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选定的灵摆区域对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 这个回合，那张卡不会被对方的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置破坏抗性：不会被对方的卡的效果破坏
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

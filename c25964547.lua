--夢現の夢魔鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「圣光之梦魔镜」「黯黑之梦魔镜」各1张从手卡·卡组选出，那之内的1张在自己的场地区域，另1张在对方的场地区域各自表侧表示放置。
function c25964547.initial_effect(c)
	-- 为这张卡注册关联卡名“圣光之梦魔镜”（74665651）与“黯黑之梦魔镜”（1050355），以便规则识别此卡效果中指定的卡名。
	aux.AddCodeList(c,74665651,1050355)
	-- 这个卡名的卡在1回合只能发动1张。①：「圣光之梦魔镜」「黯黑之梦魔镜」各1张从手卡·卡组选出，那之内的1张在自己的场地区域，另1张在对方的场地区域各自表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,25964547+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c25964547.target)
	e1:SetOperation(c25964547.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数cfilter1：判断一张卡是否可作为“放置在自己场地区域的梦魔镜”，要求其为圣光/黯黑梦魔镜之一、场上不存在同名卡、未被禁止，并且手卡/卡组中还存在另一张不同名的梦魔镜可放置在对方场地。
function c25964547.cfilter1(c,tp)
	return c:IsCode(74665651,1050355) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 进一步要求当前候选卡之外，还能从手卡·卡组找到另一张与之不同名的梦魔镜卡（由cfilter2判断）放在对方场地区域。
		and Duel.IsExistingMatchingCard(c25964547.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,tp,c:GetCode())
end
-- 定义筛选函数cfilter2：判断一张卡是否可作为“放置在对方场地区域的另一张梦魔镜”，要求其为圣光/黯黑梦魔镜之一、与第一张卡卡号不同、场上不存在同名卡、未被禁止。
function c25964547.cfilter2(c,tp,code)
	return c:IsCode(74665651,1050355) and not c:IsCode(code) and c:CheckUniqueOnField(1-tp) and not c:IsForbidden()
end
-- 定义效果的发动条件判定函数target：在发动时确认能够从手卡·卡组选出两张符合条件的梦魔镜卡，否则不能发动。
function c25964547.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（效果发动合法性检查）时，检查手卡·卡组中是否存在至少一组可分别放置在己方和对方场地区域的梦魔镜组合。
	if chk==0 then return Duel.IsExistingMatchingCard(c25964547.cfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理：从手卡·卡组各选1张圣光/黯黑梦魔镜，分别表侧放置在己方和对方的场地区域；第一张移动成功后才处理第二张，并最后对两张卡启用效果状态。
function c25964547.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要放置在自己场地区域的梦魔镜卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25964547,0))  --"请选择要放置在自己场地区域的卡"
	-- 从手卡·卡组选择1张符合条件的卡，作为放置在自己场地区域的梦魔镜。
	local g1=Duel.SelectMatchingCard(tp,c25964547.cfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	-- 提示当前玩家选择要放置在对方场地区域的梦魔镜卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25964547,1))  --"请选择要放置在对方场地区域的卡"
	-- 从手卡·卡组选择1张符合条件的卡（与第一张不同名），作为放置在对方场地区域的梦魔镜。
	local g2=Duel.SelectMatchingCard(tp,c25964547.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp,tc1:GetCode())
	local tc2=g2:GetFirst()
	-- 将第一张卡移动到自己场地区域表侧表示放置；若成功，继续执行后续放置另一张卡的操作。
	if Duel.MoveToField(tc1,tp,tp,LOCATION_FZONE,POS_FACEUP,false) then
		-- 将第二张卡移动到对方场地区域表侧表示放置；若成功，则启用第二张卡的效果状态。
		if Duel.MoveToField(tc2,tp,1-tp,LOCATION_FZONE,POS_FACEUP,false) then
			tc2:SetStatus(STATUS_EFFECT_ENABLED,true)
		end
		tc1:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end

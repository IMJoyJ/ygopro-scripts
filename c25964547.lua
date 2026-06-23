--夢現の夢魔鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「圣光之梦魔镜」「黯黑之梦魔镜」各1张从手卡·卡组选出，那之内的1张在自己的场地区域，另1张在对方的场地区域各自表侧表示放置。
function c25964547.initial_effect(c)
	-- 注册此卡可以视为拥有「圣光之梦魔镜」和「黯黑之梦魔镜」的卡名
	aux.AddCodeList(c,74665651,1050355)
	-- ①：「圣光之梦魔镜」「黯黑之梦魔镜」各1张从手卡·卡组选出，那之内的1张在自己的场地区域，另1张在对方的场地区域各自表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,25964547+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c25964547.target)
	e1:SetOperation(c25964547.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查手卡或卡组中是否有一张「圣光之梦魔镜」或「黯黑之梦魔镜」，且该卡在自己场上唯一、未被禁止，并且存在另一张符合条件的卡
function c25964547.cfilter1(c,tp)
	return c:IsCode(74665651,1050355) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查是否存在满足cfilter2条件的卡（即另一张「圣光之梦魔镜」或「黯黑之梦魔镜」，且与第一张不同、在对方场上唯一、未被禁止）
		and Duel.IsExistingMatchingCard(c25964547.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,tp,c:GetCode())
end
-- 过滤函数：检查手卡或卡组中是否有一张「圣光之梦魔镜」或「黯黑之梦魔镜」，且与第一张不同、在对方场上唯一、未被禁止
function c25964547.cfilter2(c,tp,code)
	return c:IsCode(74665651,1050355) and not c:IsCode(code) and c:CheckUniqueOnField(1-tp) and not c:IsForbidden()
end
-- 判断是否满足发动条件：手卡或卡组中存在至少一张「圣光之梦魔镜」或「黯黑之梦魔镜」
function c25964547.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：手卡或卡组中存在至少一张「圣光之梦魔镜」或「黯黑之梦魔镜」
	if chk==0 then return Duel.IsExistingMatchingCard(c25964547.cfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 发动效果：提示选择一张卡放置在自己场地区域，再选择一张卡放置在对方场地区域，并将它们移至场地区域
function c25964547.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张卡放置在自己场地区域
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25964547,0))  --"请选择要放置在自己场地区域的卡"
	-- 选择一张满足条件的卡作为放置在自己场地区的卡
	local g1=Duel.SelectMatchingCard(tp,c25964547.cfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	-- 提示玩家选择一张卡放置在对方场地区域
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25964547,1))  --"请选择要放置在对方场地区域的卡"
	-- 选择一张满足条件的卡作为放置在对方场地区的卡
	local g2=Duel.SelectMatchingCard(tp,c25964547.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp,tc1:GetCode())
	local tc2=g2:GetFirst()
	-- 将第一张选中的卡移至自己场地区域
	if Duel.MoveToField(tc1,tp,tp,LOCATION_FZONE,POS_FACEUP,false) then
		-- 将第二张选中的卡移至对方场地区域
		if Duel.MoveToField(tc2,tp,1-tp,LOCATION_FZONE,POS_FACEUP,false) then
			tc2:SetStatus(STATUS_EFFECT_ENABLED,true)
		end
		tc1:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end

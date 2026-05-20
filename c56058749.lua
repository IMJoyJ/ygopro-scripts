--ドレミコード・ムジカ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从自己场上的「七音服」灵摆怪兽卡的灵摆刻度的以下效果选择1个发动。
-- ●奇数：从自己的额外卡组把1只灵摆刻度是奇数的表侧表示的「七音服」灵摆怪兽特殊召唤。
-- ●偶数：从自己的额外卡组把1只灵摆刻度是偶数的表侧表示的「七音服」灵摆怪兽特殊召唤。
-- ●奇数和偶数：以对方场上1张卡为对象才能发动。那张卡破坏。
function c56058749.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从自己场上的「七音服」灵摆怪兽卡的灵摆刻度的以下效果选择1个发动。●奇数：从自己的额外卡组把1只灵摆刻度是奇数的表侧表示的「七音服」灵摆怪兽特殊召唤。●偶数：从自己的额外卡组把1只灵摆刻度是偶数的表侧表示的「七音服」灵摆怪兽特殊召唤。●奇数和偶数：以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,56058749+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c56058749.target)
	e1:SetOperation(c56058749.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：自己场上表侧表示的「七音服」灵摆怪兽卡
function c56058749.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 过滤函数：判定灵摆刻度是否为指定的奇数（1）或偶数（0）
function c56058749.chkfilter(c,odevity)
	return c:GetCurrentScale()%2==odevity
end
-- 过滤函数：额外卡组中表侧表示、灵摆刻度符合奇偶性要求、且可以特殊召唤的「七音服」灵摆怪兽
function c56058749.spfilter(c,e,tp,odevity)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:GetCurrentScale()%2==odevity
		-- 判定怪兽是否可以特殊召唤，且额外卡组怪兽特殊召唤所需的怪兽区域空格数大于0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判定函数：自己场上是否存在指定奇偶性刻度的「七音服」怪兽，且额外卡组是否存在可特殊召唤的对应奇偶性刻度的「七音服」怪兽
function c56058749.chkcon(g,e,tp,odevity)
	-- 检查场上是否存在对应奇偶性刻度的卡，且额外卡组存在可特殊召唤的对应奇偶性刻度的卡
	return g:IsExists(c56058749.chkfilter,1,nil,odevity) and Duel.IsExistingMatchingCard(c56058749.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,odevity)
end
-- 判定函数：自己场上是否同时存在奇数和偶数刻度的「七音服」怪兽
function c56058749.chkcon2(g,tp)
	return g:IsExists(c56058749.chkfilter,1,nil,1) and g:IsExists(c56058749.chkfilter,1,nil,0)
end
-- 效果发动时的目标选择与处理分支判定（根据场上「七音服」怪兽的刻度奇偶性，决定可选择发动的效果分支，并进行取对象或设置操作信息）
function c56058749.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 获取自己场上所有表侧表示的「七音服」灵摆怪兽卡
	local g=Duel.GetMatchingGroup(c56058749.scfilter,tp,LOCATION_ONFIELD,0,nil)
	local b1=c56058749.chkcon(g,e,tp,1)
	local b2=c56058749.chkcon(g,e,tp,0)
	-- 判定是否满足“奇数和偶数”效果的发动条件（场上同时存在奇数和偶数刻度，且对方场上有可作为对象的卡）
	local b3=c56058749.chkcon2(g,tp) and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local off=0
	local ops={}
	local opval={}
	off=1
	if b1 then
		ops[off]=aux.Stringid(56058749,0)  --"奇数特殊召唤"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(56058749,1)  --"偶数特殊召唤"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(56058749,2)  --"卡片破坏"
		opval[off-1]=3
		off=off+1
	end
	-- 让玩家从满足条件的选项中选择一个效果发动
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	if opval[op]==1 or opval[op]==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		-- 设置连锁信息：准备从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 给玩家发送提示信息：请选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1张卡作为效果的对象
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置连锁信息：准备破坏选中的那张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数：根据发动时选择的分支，执行对应的特殊召唤或破坏卡片的效果
function c56058749.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==1 or opt==2 then
		local sc=opt==1 and 1 or 0
		-- 给玩家发送提示信息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足奇偶性要求的表侧表示「七音服」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c56058749.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sc)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 获取发动时选择的作为破坏对象的卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的卡因效果破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

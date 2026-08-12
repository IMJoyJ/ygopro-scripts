--スプリガンズ・ブラスト！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「护宝炮妖」怪兽存在的场合，指定对方的主要怪兽区域1处才能发动（自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，这个效果指定的区域可以变成2处）。那个区域有表侧表示怪兽存在的场合，那只怪兽在这个回合不能直接攻击，效果无效化。那个区域没有怪兽存在的场合，这个回合，指定的区域不能使用。
function c10584050.initial_effect(c)
	-- 为卡片注册与「阿不思的落胤」相关的卡片代码列表，用于后续判断是否满足融合素材条件
	aux.AddCodeList(c,68468459)
	-- ①：自己场上有「护宝炮妖」怪兽存在的场合，指定对方的主要怪兽区域1处才能发动（自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，这个效果指定的区域可以变成2处）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,10584050+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10584050.condition)
	e1:SetTarget(c10584050.target)
	e1:SetOperation(c10584050.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否有「护宝炮妖」怪兽（0x155）
function c10584050.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155)
end
-- 效果条件函数：判断自己场上是否存在「护宝炮妖」怪兽
function c10584050.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「护宝炮妖」怪兽
	return Duel.IsExistingMatchingCard(c10584050.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查场上是否有以「阿不思的落胤」为融合素材的融合怪兽
function c10584050.cfilter(c)
	-- 检查场上是否存在以「阿不思的落胤」为融合素材的融合怪兽
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
end
-- 过滤函数：检查指定位置是否有里侧表示的怪兽
function c10584050.fdfilter(c,i)
	return c:IsFacedown() and c:GetSequence()==i
end
-- 效果发动时的处理函数：选择目标区域
function c10584050.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local fdzone=0
	for i=0,4 do
		-- 检查指定位置是否存在里侧表示的怪兽
		if Duel.IsExistingMatchingCard(c10584050.fdfilter,tp,0,LOCATION_MZONE,1,nil,i) then
			fdzone=fdzone|1<<i
		end
	end
	if chk==0 then return ~fdzone&0x1f>0 end
	-- 选择一个对方主要怪兽区域
	local dis=Duel.SelectField(tp,1,0,LOCATION_MZONE,(fdzone|0x60)<<16)
	-- 检查自己场上是否存在以「阿不思的落胤」为融合素材的融合怪兽
	if Duel.IsExistingMatchingCard(c10584050.cfilter,tp,LOCATION_MZONE,0,1,nil) and ~(fdzone|(dis>>16))&0x1f>0
		-- 询问玩家是否再选择一个区域
		and Duel.SelectYesNo(tp,aux.Stringid(10584050,0)) then  --"是否再选择1个区域？"
		-- 再选择一个对方主要怪兽区域
		dis=dis|Duel.SelectField(tp,1,0,LOCATION_MZONE,(fdzone|(dis>>16)|0x60)<<16)
	end
	e:SetLabel(dis)
	-- 提示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 过滤函数：检查指定位置是否有表侧表示的怪兽
function c10584050.disfilter2(c,dis)
	return c:IsFaceup() and (2^c:GetSequence())*0x10000&dis~=0
end
-- 过滤函数：检查指定位置是否有里侧表示的怪兽
function c10584050.disfilter3(c,dis)
	return c:IsFacedown() and (2^c:GetSequence())*0x10000&dis~=0
end
-- 效果发动时的处理函数：执行效果
function c10584050.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dis=e:GetLabel()
	-- 获取所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c10584050.disfilter2,tp,0,LOCATION_MZONE,nil,dis)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽不能直接攻击
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0)
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化状态持续到结束阶段
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		dis=dis-(2^tc:GetSequence())*0x10000
		tc=g:GetNext()
	end
	-- 获取所有里侧表示的怪兽
	local sg=Duel.GetMatchingGroup(c10584050.disfilter3,tp,0,LOCATION_MZONE,nil,dis)
	local sc=sg:GetFirst()
	while sc do
		dis=dis-(2^sc:GetSequence())*0x10000
		sc=sg:GetNext()
	end
	if dis~=0 then
		if tp==1 then
			dis=((dis&0xffff)<<16)|((dis>>16)&0xffff)
		end
		-- 使指定区域在本回合不能使用
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_FIELD)
		e3:SetValue(dis)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家全局环境
		Duel.RegisterEffect(e3,tp)
	end
end

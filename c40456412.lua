--覇王龍の奇跡
-- 效果：
-- ①：自己场上有「霸王龙 扎克」存在的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己场上1张「霸王龙 扎克」破坏，从卡组·额外卡组把1只「异色眼」灵摆怪兽或者光属性「霸王龙 扎克」无视召唤条件特殊召唤。
-- ●自己的额外卡组1只表侧的灵摆怪兽在自己的灵摆区域放置。
-- ●从卡组把1张速攻魔法卡在自己场上盖放。
function c40456412.initial_effect(c)
	-- 注册此卡具有「霸王龙 扎克」的卡名信息
	aux.AddCodeList(c,13331639)
	-- ①：自己场上有「霸王龙 扎克」存在的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40456412,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c40456412.condition)
	e1:SetTarget(c40456412.target)
	e1:SetOperation(c40456412.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「霸王龙 扎克」
function c40456412.cfilter(c)
	return c:IsCode(13331639) and c:IsFaceup()
end
-- 效果发动的条件，判断自己场上是否存在表侧表示的「霸王龙 扎克」
function c40456412.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在表侧表示的「霸王龙 扎克」
	return Duel.IsExistingMatchingCard(c40456412.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「霸王龙 扎克」
function c40456412.desfilter(c)
	return c:IsCode(13331639) and c:IsFaceup()
end
-- 过滤函数，用于判断是否可以特殊召唤的「异色眼」灵摆怪兽或光属性「霸王龙 扎克」
function c40456412.spfilter(c,e,tp)
	return ((c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)) or (c:IsCode(13331639) and c:IsAttribute(ATTRIBUTE_LIGHT)))
		-- 判断卡组中是否有足够的怪兽区域可以特殊召唤
		and ((c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 判断额外卡组中是否有足够的怪兽区域可以特殊召唤
		or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 过滤函数，用于判断额外卡组中是否存在表侧表示且未被禁止的灵摆怪兽
function c40456412.psfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
-- 过滤函数，用于判断卡组中是否存在可以盖放的速攻魔法卡
function c40456412.ssfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 效果的发动时点处理，判断是否可以发动任意一个效果并选择效果
function c40456412.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示的「霸王龙 扎克」
	local g1=Duel.GetMatchingGroup(c40456412.desfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 获取可以特殊召唤的「异色眼」灵摆怪兽或光属性「霸王龙 扎克」
	local g2=Duel.GetMatchingGroup(c40456412.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
	-- 判断是否已使用过效果1（破坏并特殊召唤）
	local b1=(Duel.GetFlagEffect(tp,40456412+1)==0 or not e:IsCostChecked())
		and g1:GetCount()>0 and g2:GetCount()>0
	-- 判断是否已使用过效果2（放置灵摆怪兽）
	local b2=(Duel.GetFlagEffect(tp,40456412+2)==0 or not e:IsCostChecked())
		-- 判断自己灵摆区域是否有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 判断额外卡组中是否存在表侧表示且未被禁止的灵摆怪兽
		and Duel.IsExistingMatchingCard(c40456412.psfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 判断是否已使用过效果3（盖放速攻魔法卡）
	local b3=(Duel.GetFlagEffect(tp,40456412+3)==0 or not e:IsCostChecked())
		-- 判断卡组中是否存在可以盖放的速攻魔法卡
		and Duel.IsExistingMatchingCard(c40456412.ssfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家选择发动的效果
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(40456412,1)},  --"破坏并特殊召唤"
		{b2,aux.Stringid(40456412,2)},  --"从额外卡组放置灵摆怪兽"
		{b3,aux.Stringid(40456412,3)})  --"从卡组盖放速攻魔法卡"
	if e:IsCostChecked() then
		-- 注册已使用的效果编号，防止重复使用
		Duel.RegisterFlagEffect(tp,40456412+op,RESET_PHASE+PHASE_END,0,1)
	end
	e:SetLabel(op)
	if op==1 then
		-- 设置操作信息，表示将要破坏1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
		-- 设置操作信息，表示将要特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(0)
		end
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SSET)
		end
	end
end
-- 效果发动的处理函数，根据选择的效果执行对应操作
function c40456412.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		c40456412.spop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		c40456412.psop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		c40456412.ssop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 处理效果1的特殊召唤操作，先破坏1张「霸王龙 扎克」再特殊召唤1只怪兽
function c40456412.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的「霸王龙 扎克」
	local g1=Duel.SelectMatchingCard(tp,c40456412.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 获取可以特殊召唤的「异色眼」灵摆怪兽或光属性「霸王龙 扎克」
	local g2=Duel.GetMatchingGroup(c40456412.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
	-- 执行破坏操作并判断是否满足特殊召唤条件
	if Duel.Destroy(g1,REASON_EFFECT)>0 and g2:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g2:Select(tp,1,1,nil)
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 处理效果2的灵摆怪兽放置操作
function c40456412.psop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己灵摆区域是否有空位
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择要放置的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c40456412.psfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的灵摆怪兽放置到灵摆区域
	if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,false) then
		tc:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end
-- 处理效果3的速攻魔法卡盖放操作
function c40456412.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的速攻魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择要盖放的速攻魔法卡
	local g=Duel.SelectMatchingCard(tp,c40456412.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的速攻魔法卡盖放到场上
		Duel.SSet(tp,g:GetFirst())
	end
end

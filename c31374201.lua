--海造賊－白髭の機関士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，自己场上的这张卡当作装备卡使用给那只怪兽装备。
-- ②：这张卡从手卡·怪兽区域送去墓地的场合才能发动。从卡组把「海造贼-白胡子机关士」以外的1只「海造贼」怪兽特殊召唤。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
function c31374201.initial_effect(c)
	-- 效果①：对方回合才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，自己场上的这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31374201,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,31374201)
	e1:SetCondition(c31374201.spcon1)
	e1:SetTarget(c31374201.sptg1)
	e1:SetOperation(c31374201.spop1)
	c:RegisterEffect(e1)
	-- 效果②：这张卡从手卡·怪兽区域送去墓地的场合才能发动。从卡组把「海造贼-白胡子机关士」以外的1只「海造贼」怪兽特殊召唤。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31374201,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31374202)
	e2:SetCondition(c31374201.spcon2)
	e2:SetTarget(c31374201.sptg2)
	e2:SetOperation(c31374201.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前回合玩家为对方
function c31374201.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果①的发动条件检查函数：检查对方场上或墓地是否有「海造贼」怪兽
function c31374201.cfilter(c,e,tp)
	-- 检查对方场上或墓地是否有「海造贼」怪兽
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and Duel.IsExistingMatchingCard(c31374201.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
-- 效果①的特殊召唤目标过滤函数：筛选满足条件的「海造贼」怪兽
function c31374201.spfilter1(c,e,tp,attr)
	-- 筛选满足条件的「海造贼」怪兽
	return c:IsSetCard(0x13f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动时点处理函数：检查是否满足发动条件
function c31374201.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的魔陷区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上或墓地是否有「海造贼」怪兽
		and Duel.IsExistingMatchingCard(c31374201.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置效果①的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果①的装备操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 用于筛选对方场上或墓地的「海造贼」怪兽的过滤函数
function c31374201.cfilter2(c)
	return c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
-- 效果①的处理函数：检索满足条件的怪兽并特殊召唤，然后装备给该怪兽
function c31374201.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上或墓地的「海造贼」怪兽
	local g=Duel.GetMatchingGroup(c31374201.cfilter2,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local tc=g:GetFirst()
	local attr=0
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「海造贼」怪兽
	local sg=Duel.SelectMatchingCard(tp,c31374201.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,attr)
	local sc=sg:GetFirst()
	-- 判断特殊召唤是否成功并进行装备操作
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 and sc:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) then
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 尝试将自己装备给目标怪兽
		if not Duel.Equip(tp,c,sc,false) then return end
		-- 设置装备限制效果：只能装备给特定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(sc)
		e1:SetValue(c31374201.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数：只能装备给特定怪兽
function c31374201.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的发动条件：这张卡从手卡或怪兽区域送去墓地
function c31374201.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE)
end
-- 效果②的特殊召唤目标过滤函数：筛选满足条件的「海造贼」怪兽
function c31374201.spfilter2(c,e,tp)
	return c:IsSetCard(0x13f) and not c:IsCode(31374201) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时点处理函数：检查是否满足发动条件
function c31374201.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有满足条件的「海造贼」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c31374201.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果②的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数：特殊召唤满足条件的怪兽并设置本回合不能特殊召唤非「海造贼」怪兽的效果
function c31374201.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有足够的怪兽区空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「海造贼」怪兽
		local g=Duel.SelectMatchingCard(tp,c31374201.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置本回合不能特殊召唤非「海造贼」怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31374201.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 不能特殊召唤的判断函数：非「海造贼」怪兽不能特殊召唤
function c31374201.splimit(e,c)
	return not c:IsSetCard(0x13f)
end

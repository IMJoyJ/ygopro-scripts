--RUM－ラプターズ・フォース
-- 效果：
-- ①：自己场上的「急袭猛禽」超量怪兽被破坏送去墓地的回合，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c43383478.initial_effect(c)
	-- 效果原文内容：①：自己场上的「急袭猛禽」超量怪兽被破坏送去墓地的回合，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_DESTROY+TIMING_END_PHASE)
	e1:SetCondition(c43383478.condition)
	e1:SetTarget(c43383478.target)
	e1:SetOperation(c43383478.activate)
	c:RegisterEffect(e1)
	if not c43383478.globle_check then
		c43383478.globle_check=true
		-- 效果原文内容：那只怪兽特殊召唤，比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c43383478.checkop)
		-- 将效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有卡进入墓地时，检查是否为「急袭猛禽」超量怪兽被破坏，若为己方则注册标识效果
function c43383478.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsSetCard(0xba) and tc:IsType(TYPE_XYZ) and tc:IsReason(REASON_DESTROY) then
			if tc:IsPreviousControler(0) then p1=true else p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若己方有「急袭猛禽」超量怪兽被破坏，则注册标识效果
	if p1 then Duel.RegisterFlagEffect(0,43383478,RESET_PHASE+PHASE_END,0,1) end
	-- 若对方有「急袭猛禽」超量怪兽被破坏，则注册标识效果
	if p2 then Duel.RegisterFlagEffect(1,43383478,RESET_PHASE+PHASE_END,0,1) end
end
-- 效果原文内容：自己场上的「急袭猛禽」超量怪兽被破坏送去墓地的回合
function c43383478.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否己方有「急袭猛禽」超量怪兽被破坏的标识效果
	return Duel.GetFlagEffect(tp,43383478)~=0
end
-- 过滤满足条件的墓地「急袭猛禽」超量怪兽，用于特殊召唤
function c43383478.filter1(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查该怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在满足条件的额外卡组「急袭猛禽」怪兽用于超量召唤
		and Duel.IsExistingMatchingCard(c43383478.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
end
-- 过滤满足条件的额外卡组「急袭猛禽」怪兽，用于超量召唤
function c43383478.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以特殊召唤且有足够空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置目标选择函数，用于选择墓地中的「急袭猛禽」超量怪兽
function c43383478.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43383478.filter1(chkc,e,tp) end
	-- 检查己方是否可以进行两次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查己方场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地是否存在满足条件的「急袭猛禽」超量怪兽
		and Duel.IsExistingTarget(c43383478.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地「急袭猛禽」超量怪兽作为目标
	local g=Duel.SelectTarget(tp,c43383478.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果处理函数，执行特殊召唤和超量召唤操作
function c43383478.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 将目标怪兽特殊召唤到己方场上
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查目标怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组「急袭猛禽」怪兽用于超量召唤
	local g=Duel.SelectMatchingCard(tp,c43383478.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到选中的额外怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选中的额外怪兽从额外卡组特殊召唤到己方场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

--RUM－ラプターズ・フォース
-- 效果：
-- ①：自己场上的「急袭猛禽」超量怪兽被破坏送去墓地的回合，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c43383478.initial_effect(c)
	-- ①：自己场上的「急袭猛禽」超量怪兽被破坏送去墓地的回合，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
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
		-- 自己场上的「急袭猛禽」超量怪兽被破坏送去墓地的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c43383478.checkop)
		-- 以玩家0为基准注册一个全场持续效果，监听怪兽被送去墓地的事件，以便在「急袭猛禽」超量怪兽被破坏送墓时为对应玩家设置发动条件标记。
		Duel.RegisterEffect(ge1,0)
	end
end
-- checkop：当有怪兽被送去墓地时，遍历本次送去墓地的怪兽，若存在「急袭猛禽」超量怪兽且因破坏而送墓，则根据其原控制者分别记录本回合满足发动条件。
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
	-- 若玩家0场上的「急袭猛禽」超量怪兽被破坏送去墓地，则给玩家0注册一个直到结束阶段有效的flag，表示其本回合满足发动条件。
	if p1 then Duel.RegisterFlagEffect(0,43383478,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1场上的「急袭猛禽」超量怪兽被破坏送去墓地，则给玩家1注册一个直到结束阶段有效的flag，表示其本回合满足发动条件。
	if p2 then Duel.RegisterFlagEffect(1,43383478,RESET_PHASE+PHASE_END,0,1) end
end
-- condition：发动条件的判定函数，检查发动者本方是否持有对应flag，即本回合自己场上是否有「急袭猛禽」超量怪兽被破坏送去墓地。
function c43383478.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家tp存在43383478号flag的数量，若不为0则满足发动条件。
	return Duel.GetFlagEffect(tp,43383478)~=0
end
-- filter1：墓地对象候选的筛选条件——是「急袭猛禽」超量怪兽、可被特殊召唤、可作为超量素材且额外卡组存在高1阶的「急袭猛禽」超量怪兽。
function c43383478.filter1(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认该怪兽没有受到‘必须作为超量素材’等效果限制，仍能作为超量素材使用。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足filter2的「急袭猛禽」超量怪兽，其阶级为对象怪兽阶级+1，且可用于叠放超量召唤。
		and Duel.IsExistingMatchingCard(c43383478.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
end
-- filter2：额外卡组候选怪兽的筛选条件——阶级等于指定阶级、是「急袭猛禽」怪兽、对象怪兽可作为其超量素材、能以超量召唤方式特殊召唤，且从额外卡组特殊召唤时有空位。
function c43383478.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 确认该额外怪兽可以以超量召唤方式被特殊召唤，且从额外卡组出场时有可用区域（不会被额外怪兽区占用等问题阻碍）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- target：发动时检查合法性与选择对象。先判定指定对象是否合法，再检查玩家能否进行2次特殊召唤、场上是否有空位、墓地是否有符合条件的对象，然后选择1只墓地「急袭猛禽」超量怪兽。
function c43383478.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43383478.filter1(chkc,e,tp) end
	-- 发动条件检查：在当前玩家还能进行至少2次特殊召唤时才允许发动，因为处理中要先特殊召唤墓地怪兽，再超量召唤额外怪兽。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己主要怪兽区是否有空位，用于后续特殊召唤墓地怪兽及超量召唤额外怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足filter1的「急袭猛禽」超量怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c43383478.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示‘请选择要特殊召唤的卡’的提示信息，引导玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足filter1的「急袭猛禽」超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c43383478.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果涉及从额外卡组进行2次特殊召唤（目标为g，预计数量2，来自额外卡组），用于触发时点检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- activate：效果处理。先特殊召唤对象怪兽，再从额外卡组选择一只比它阶级高1阶的「急袭猛禽」超量怪兽，将其叠放在对象怪兽上以超量召唤方式特殊召唤。
function c43383478.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则无法进行后续特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果发动时选择的墓地「急袭猛禽」超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 将对象怪兽从墓地特殊召唤到场上；若特殊召唤失败（返回0），则中止效果处理。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 再次确认对象怪兽仍可作为超量素材，若因效果限制不能作为素材则中止。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 显示‘请选择要特殊召唤的卡’的提示信息，用于选择额外卡组中要超量召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter2的「急袭猛禽」超量怪兽，其阶级必须比对象怪兽高1。
	local g=Duel.SelectMatchingCard(tp,c43383478.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		-- 中断当前效果处理，使后续的超量召唤视为另一次处理，避免错失时点。
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽tc作为超量素材叠放在额外怪兽sc下方，完成超量召唤的叠放操作。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤方式将额外怪兽sc特殊召唤到场上，实现‘在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤’。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

--メルフィー・ラッシィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「童话动物·小海豹」以外的自己场上的表侧表示的兽族怪兽回到手卡的自己·对方回合才能发动。这张卡从手卡特殊召唤。那之后，可以只用这张卡和手卡的「童话动物」怪兽为素材进行同调召唤。
-- ②：自己结束阶段有这张卡在墓地存在的场合，以自己场上1只兽族超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
function c34800281.initial_effect(c)
	-- ①：「童话动物·小海豹」以外的自己场上的表侧表示的兽族怪兽回到手卡的自己·对方回合才能发动。这张卡从手卡特殊召唤。那之后，可以只用这张卡和手卡的「童话动物」怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34800281,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34800281)
	e1:SetHintTiming(0,TIMING_CHAIN_END+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c34800281.syncon)
	e1:SetTarget(c34800281.syntg)
	e1:SetOperation(c34800281.synop)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段有这张卡在墓地存在的场合，以自己场上1只兽族超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34800281,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,34800282)
	e2:SetCondition(c34800281.xyzcon)
	e2:SetTarget(c34800281.xyztg)
	e2:SetOperation(c34800281.xyzop)
	c:RegisterEffect(e2)
	if not c34800281.global_check then
		c34800281.global_check=true
		-- 为玩家0和1注册一个在EVENT_TO_HAND时触发的效果，用于记录是否有兽族怪兽从场上回到手牌
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_TO_HAND)
		e0:SetOperation(c34800281.regop)
		-- 将效果e0注册给玩家0，使其成为全局效果
		Duel.RegisterEffect(e0,0)
	end
end
-- 过滤函数，用于判断一张卡是否为从场上离开的兽族怪兽（且不是小海豹）
function c34800281.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousRaceOnField()&RACE_BEAST)>0
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsCode(34800281)
end
-- 当有卡进入手牌时，检查是否有满足条件的兽族怪兽离开过场上，若有则为对应玩家注册标识效果
function c34800281.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(c34800281.cfilter,1,nil,p) then
			-- 为玩家p注册一个标识效果，该效果在结束阶段重置，用于标记该玩家在本回合中是否满足①效果的发动条件
			Duel.RegisterFlagEffect(p,34800281,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 判断当前玩家是否拥有标识效果，用于判断①效果是否可以发动
function c34800281.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否拥有标识效果，用于判断①效果是否可以发动
	return Duel.GetFlagEffect(tp,34800281)>0
end
-- 设置连锁处理时的提示信息，表示将要特殊召唤这张卡
function c34800281.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场地空间用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理时的提示信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数，用于判断一张卡是否可以作为同调素材且属于童话动物卡组
function c34800281.synhfilter(c,sc,tuner)
	return c:IsCanBeSynchroMaterial(sc,tuner) and c:IsSetCard(0x146)
end
-- 过滤函数，用于判断一张卡是否可以进行同调召唤且满足场地条件
function c34800281.synfilter(c,mc,tp)
	-- 获取满足条件的童话动物卡组作为同调素材
	local mg=Duel.GetMatchingGroup(c34800281.synhfilter,tp,LOCATION_HAND,0,nil,c,mc)
	mg:AddCard(mc)
	-- 判断该卡是否可以进行同调召唤且满足场地条件
	return c:IsSynchroSummonable(mc,mg) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 处理①效果的发动，先将自身特殊召唤，再判断是否进行同调召唤
function c34800281.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否可以特殊召唤，若不能则直接返回
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查是否存在满足条件的同调怪兽，用于判断是否可以进行同调召唤
	if Duel.IsExistingMatchingCard(c34800281.synfilter,tp,LOCATION_EXTRA,0,1,nil,c,tp)
		-- 询问玩家是否进行同调召唤
		and Duel.SelectYesNo(tp,aux.Stringid(34800281,2)) then  --"是否同调召唤？"
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的同调怪兽
		local fc=Duel.SelectMatchingCard(tp,c34800281.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,c,tp):GetFirst()
		-- 获取满足条件的童话动物卡组作为同调素材
		local mg=Duel.GetMatchingGroup(c34800281.synhfilter,tp,LOCATION_HAND,0,nil,fc,c)
		mg:AddCard(c)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,fc,c,mg)
	end
end
-- 判断当前是否为该玩家的结束阶段
function c34800281.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为该玩家的结束阶段
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，用于判断一张卡是否为兽族超量怪兽
function c34800281.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_BEAST) and c:IsFaceup()
end
-- 设置连锁处理时的提示信息，表示将要选择目标
function c34800281.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34800281.xyzfilter(chkc) end
	-- 检查是否存在满足条件的兽族超量怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c34800281.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的兽族超量怪兽作为目标
	Duel.SelectTarget(tp,c34800281.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理时的提示信息，表示将要将该卡从墓地移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 处理②效果的发动，将该卡作为目标怪兽的超量素材
function c34800281.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将该卡叠放在目标怪兽上
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

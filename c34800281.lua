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
		-- ①：「童话动物·小海豹」以外的自己场上的表侧表示的兽族怪兽回到手卡的自己·对方回合才能发动。
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_TO_HAND)
		e0:SetOperation(c34800281.regop)
		-- 将全局监测效果e0注册到游戏中，持续监听“卡加入手卡”的事件，用于判断①效果的发动条件（表侧兽族怪兽回手）是否被满足。
		Duel.RegisterEffect(e0,0)
	end
end
-- 过滤函数：判断回到手卡的卡是否满足：之前由自己控制、从主要怪兽区离开、表侧表示、种族为兽族、且卡名不是『童话动物·小海豹』。
function c34800281.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousRaceOnField()&RACE_BEAST)>0
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsCode(34800281)
end
-- 当有卡加入手卡时，遍历双方玩家，若存在满足“自己场上的表侧表示兽族怪兽回到手卡”条件的卡，则为对应玩家登记flag标记，以开放①效果的发动。
function c34800281.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(c34800281.cfilter,1,nil,p) then
			-- 为玩家p登记一个标记，表示该玩家本回合已满足“表侧兽族怪兽回到手卡”的发动条件；该标记在结束阶段重置。
			Duel.RegisterFlagEffect(p,34800281,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- ①效果的发动条件：检查当前玩家本回合是否已登记过“表侧兽族怪兽回到手卡”的标记。
function c34800281.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家tp是否存在编号34800281的标记（数量大于0），存在则①效果满足发动条件。
	return Duel.GetFlagEffect(tp,34800281)>0
end
-- ①效果发动时的合法性检查：确认自己场上主要怪兽区有空位，且手卡的这张卡能够被特殊召唤。
function c34800281.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有空位，用于判断能否从手卡特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本效果将进行特殊召唤，对象为这张卡，数量为1，属于CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数：筛选手卡中可作为同调素材、且属于『童话动物』系列的怪兽。
function c34800281.synhfilter(c,sc,tuner)
	return c:IsCanBeSynchroMaterial(sc,tuner) and c:IsSetCard(0x146)
end
-- 过滤函数：筛选额外卡组中能够以“这张卡+手卡中符合条件的『童话动物』怪兽”为素材进行同调召唤的同调怪兽，并确认额外怪兽区有空位。
function c34800281.synfilter(c,mc,tp)
	-- 获取手卡中所有可作为同调素材的『童话动物』怪兽，组成同调素材候选组mg。
	local mg=Duel.GetMatchingGroup(c34800281.synhfilter,tp,LOCATION_HAND,0,nil,c,mc)
	mg:AddCard(mc)
	-- 确认该同调怪兽c能够以调整怪兽mc和素材组mg进行同调召唤，并且额外卡组怪兽有可用的特殊召唤区域。
	return c:IsSynchroSummonable(mc,mg) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果的处理：先将这张卡从手卡特殊召唤；成功后，若玩家选择进行同调召唤，则从额外卡组选择合适的同调怪兽，以这张卡和手卡的『童话动物』怪兽为素材进行同调召唤。
function c34800281.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联，并尝试将其从手卡特殊召唤；若未关联或特殊召唤失败，则结束处理。
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查额外卡组中是否存在满足“以这张卡和手卡童话动物怪兽为素材可同调召唤”的同调怪兽。
	if Duel.IsExistingMatchingCard(c34800281.synfilter,tp,LOCATION_EXTRA,0,1,nil,c,tp)
		-- 询问玩家是否进行同调召唤；只有玩家选择“是”时才继续执行同调召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(34800281,2)) then  --"是否同调召唤？"
		-- 中断当前效果处理，使后续的同调召唤作为独立处理插入，避免错过时点。
		Duel.BreakEffect()
		-- 提示玩家从额外卡组选择要特殊召唤的同调怪兽（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从符合条件的额外卡组同调怪兽中选择一只，作为同调召唤的目标fc。
		local fc=Duel.SelectMatchingCard(tp,c34800281.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,c,tp):GetFirst()
		-- 获取手卡中所有可作为同调素材的『童话动物』怪兽，用于随后的同调召唤。
		local mg=Duel.GetMatchingGroup(c34800281.synhfilter,tp,LOCATION_HAND,0,nil,fc,c)
		mg:AddCard(c)
		-- 执行同调召唤：以这张卡为调整怪兽，手卡中的『童话动物』怪兽为素材，将fc从额外卡组特殊召唤。
		Duel.SynchroSummon(tp,fc,c,mg)
	end
end
-- ②效果的发动条件：自己的结束阶段（当前回合玩家为自己）。
function c34800281.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保②效果只在己方结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：筛选自己场上表侧表示的兽族超量怪兽，作为②效果可选对象。
function c34800281.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_BEAST) and c:IsFaceup()
end
-- ②效果的发动时点处理：选择自己场上1只表侧表示兽族超量怪兽为对象，并登记操作信息。
function c34800281.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34800281.xyzfilter(chkc) end
	-- 发动时检查自己场上是否存在符合条件的兽族超量怪兽，作为能否取对象发动的判定。
	if chk==0 then return Duel.IsExistingTarget(c34800281.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象（兽族超量怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的兽族超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c34800281.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：此效果处理时这张卡将离开墓地（成为超量素材），属于CATEGORY_LEAVE_GRAVE。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：将墓地中的这张卡作为对象超量怪兽的超量素材叠放。
function c34800281.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象（兽族超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将这张卡从墓地叠放在对象超量怪兽下方，作为其超量素材。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

--従騎士トゥルーデア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上的这张卡和除「从骑士 特露迪娅」以外的手卡·卡组1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合，自己不能把「从骑士 特露迪娅」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级上升4星。
local s,id,o=GetID()
-- 注册此卡的两个效果：①起动效果（自己主要阶段可发动，将自身和手卡·卡组1只「百夫长骑士」怪兽当作永续陷阱卡放置到魔陷区，且该回合不能再特殊召唤此卡）；②诱发即时效果（当作永续陷阱卡时，双方主要阶段可特殊召唤自身并选择是否上升4星）。
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。自己场上的这张卡和除「从骑士 特露迪娅」以外的手卡·卡组1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合，自己不能把「从骑士 特露迪娅」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级上升4星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数：筛选属于「百夫长骑士」系列（0x1a2）的怪兽卡，且不是禁止卡，也不是「从骑士 特露迪娅」自身（id）。
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsCode(id)
end
-- ①效果的发动条件：己方手卡·卡组中存在符合条件的「百夫长骑士」怪兽，且己方魔法与陷阱区域空格数大于1，才能发动。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认己方手卡·卡组中至少有1张满足s.filter的「百夫长骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
		-- 确认己方魔法与陷阱区域的可使用空格数大于1，用于放置此卡和检索的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 end
end
-- 处理①效果：若此卡仍与效果关联且控制权在己方、魔陷区空位足够，则从手卡·卡组选1只「百夫长骑士」怪兽，将此卡与选择的怪兽表侧放置到己方魔陷区，并分别赋予“当作永续陷阱卡使用”的效果；随后给己方附加本回合不能特殊召唤「从骑士 特露迪娅」的限制。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时确认发动效果的此卡仍与效果关联、控制权仍为己方，并且魔陷区空格多于1，才继续执行放置。
	if c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 then
		-- 向己方玩家显示选择提示，要求选择一张要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从己方手卡·卡组中选择1张满足s.filter的「百夫长骑士」怪兽（效果处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将自身从怪兽区域移动到己方魔法与陷阱区域，表侧表示放置，并立即适用其效果。
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 自己场上的这张卡……当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			c:RegisterEffect(e1)
			-- 将选择的「百夫长骑士」怪兽移动到己方魔法与陷阱区域，表侧表示放置，并立即适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 除「从骑士 特露迪娅」以外的手卡·卡组1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
			local e2=Effect.CreateEffect(c)
			e2:SetCode(EFFECT_CHANGE_TYPE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e2:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			tc:RegisterEffect(e2)
		end
	end
	-- 这个回合，自己不能把「从骑士 特露迪娅」特殊召唤。②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级上升4星。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将该回合限制效果注册给己方玩家：己方不能特殊召唤「从骑士 特露迪娅」，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 限制效果的判定：仅禁止特殊召唤卡号等于id的「从骑士 特露迪娅」。
function s.splimit(e,c)
	return c:IsCode(id)
end
-- ②效果的发动条件：当前为主要阶段1或主要阶段2，且此卡在场上的种类为陷阱+永续（即处于当作永续陷阱卡的状态）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- ②效果的发动条件：己方主要怪兽区有空位，且可以进行「从骑士 特露迪娅」的特殊召唤（符合其召唤条件），并设置操作信息为特殊召唤此卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方是否可以特殊召唤「从骑士 特露迪娅」怪兽（卡号id，系列0x1a2，效果怪兽，1000/2000，4星，炎族，暗属性，表侧表示）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT,1000,2000,4,RACE_PYRO,ATTRIBUTE_DARK) end
	-- 向系统登记本次效果将进行特殊召唤，对象为此卡（e:GetHandler()），数量为1，以便后续发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理②效果：若此卡仍与效果关联，则将其特殊召唤；成功后询问玩家是否上升等级，选择是则先中断效果处理，再给此卡附加等级+4的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 特殊召唤此卡成功，且玩家选择‘是’（上升等级）时，执行后续等级上升处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否上升等级？"
		-- 中断当前效果处理，使后续等级上升效果视为独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 那之后，可以让这张卡的等级上升4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(4)
		c:RegisterEffect(e1)
	end
end

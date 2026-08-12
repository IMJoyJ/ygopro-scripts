--超重武者コブ－C
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「超重武者」怪兽战斗破坏对方怪兽的自己战斗阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，以自己场上1只「超重武者」同调怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。这个效果的发动后，直到回合结束时自己不是「超重武者」怪兽不能特殊召唤。
function c71386411.initial_effect(c)
	-- ①：自己的「超重武者」怪兽战斗破坏对方怪兽的自己战斗阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71386411,0))  --"同调召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,71386411)
	e1:SetCondition(c71386411.sccon)
	e1:SetTarget(c71386411.sctg)
	e1:SetOperation(c71386411.scop)
	c:RegisterEffect(e1)
	-- ②：自己墓地没有魔法·陷阱卡存在的场合，以自己场上1只「超重武者」同调怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。这个效果的发动后，直到回合结束时自己不是「超重武者」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71386411,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,71386412)
	e2:SetCondition(c71386411.spcon)
	e2:SetTarget(c71386411.sptg)
	e2:SetOperation(c71386411.spop)
	c:RegisterEffect(e2)
	if not c71386411.global_check then
		c71386411.global_check=true
		c71386411[0]=false
		c71386411[1]=false
		-- ①：自己的「超重武者」怪兽战斗破坏对方怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_BATTLE_DESTROYING)
		ge1:SetOperation(c71386411.checkop)
		-- 注册全局效果，用于记录本回合是否有「超重武者」怪兽战斗破坏对方怪兽。
		Duel.RegisterEffect(ge1,0)
		-- ①：自己的「超重武者」怪兽战斗破坏对方怪兽的自己战斗阶段才能发动
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c71386411.clear)
		-- 注册全局效果，在每个回合开始时重置战斗破坏标记。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 战斗破坏怪兽时触发，若是我方的「超重武者」怪兽战斗破坏了对方怪兽，则将对应玩家的战斗破坏标记设为true。
function c71386411.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE)
		and tc:IsFaceup() and tc:IsSetCard(0x9a) then
		c71386411[tc:GetControler()]=true
	end
end
-- 重置双方玩家的战斗破坏标记为false。
function c71386411.clear(e,tp,eg,ep,ev,re,r,rp)
	c71386411[0]=false
	c71386411[1]=false
end
-- 效果①的发动条件：本回合有「超重武者」怪兽战斗破坏过对方怪兽，且在自己的战斗阶段。
function c71386411.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否在本回合有「超重武者」怪兽战斗破坏过对方怪兽，且当前是自己的战斗阶段。
	return c71386411[tp] and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果①的靶向/发动准备：检查额外卡组是否存在可以以这张卡为素材进行同调召唤的怪兽，并设置特殊召唤的操作信息。
function c71386411.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以以这张卡为素材进行同调召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的运行：选择额外卡组中可以以这张卡为素材同调召唤的怪兽，并进行同调召唤。
function c71386411.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中可以以这张卡为素材进行同调召唤的怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选定的怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- 效果②的发动条件：自己墓地没有魔法·陷阱卡存在。
function c71386411.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法或陷阱卡。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：场上表侧表示、等级2以上、属于「超重武者」系列的同调怪兽。
function c71386411.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsSetCard(0x9a) and c:IsType(TYPE_SYNCHRO)
end
-- 效果②的靶向/发动准备：选择自己场上1只「超重武者」同调怪兽为对象，并设置特殊召唤的操作信息。
function c71386411.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c71386411.filter(chkc) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在满足条件的「超重武者」同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(c71386411.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要下降等级的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(71386411,2))  --"请选择要下降等级的怪兽"
	-- 选择自己场上1只表侧表示的「超重武者」同调怪兽作为效果对象。
	Duel.SelectTarget(tp,c71386411.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置特殊召唤的操作信息（从墓地特殊召唤这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的运行：添加特殊召唤限制，使目标怪兽等级下降1星，并将这张卡从墓地特殊召唤。
function c71386411.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71386411.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家在本回合只能特殊召唤「超重武者」怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsLevel(1) then return end
	-- 那只怪兽的等级下降1星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(-1)
	tc:RegisterEffect(e2)
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 特殊召唤限制的过滤函数，限制只能特殊召唤「超重武者」怪兽。
function c71386411.splimit(e,c)
	return not c:IsSetCard(0x9a)
end

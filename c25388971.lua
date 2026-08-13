--燦幻開花
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，自己场上的怪兽只有龙族·炎属性怪兽，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这次主要阶段结束。
-- ②：3次以上攻击宣言过的自己·对方回合，把墓地的这张卡除外才能发动。自己抽1张。那之后，可以从手卡把「天杯龙」怪兽任意数量特殊召唤。
local s,id,o=GetID()
-- 注册这张卡的①②两个效果：①是魔法卡发动效果，在主阶段满足条件时发动并结束主要阶段；②是墓地发动的二速效果，除外自身后抽卡并可特殊召唤「天杯龙」怪兽；同时注册一个全场攻击宣言计数效果，用于累计攻击宣言次数。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段，自己场上的怪兽只有龙族·炎属性怪兽，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这次主要阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"结束主要阶段"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.skipcon)
	e1:SetOperation(s.skipop)
	c:RegisterEffect(e1)
	-- ②：3次以上攻击宣言过的自己·对方回合，把墓地的这张卡除外才能发动。自己抽1张。那之后，可以从手卡把「天杯龙」怪兽任意数量特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡&特殊召唤"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	-- 设置②效果的发动代价为：把墓地中的这张卡除外（aux.bfgcost封装了除外自身作为COST的判定与处理）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- ②：3次以上攻击宣言过的自己·对方回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(s.checkop)
		-- 将全局持续效果注册给全场：每当任意玩家进行攻击宣言时，触发checkop累计攻击宣言次数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时，为攻击宣言方和对方都注册1个本回合结束复位的id标记，用于记录本回合双方合计的攻击宣言次数。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家（攻击宣言方）注册1个id标记，持续到回合结束，用于累计本回合攻击宣言次数。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 给对方玩家也注册1个相同的id标记，因为②条件统计的是本回合双方攻击宣言的总次数（自己·对方回合）。
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 怪兽筛选条件：表侧表示且种族为龙族、属性为炎属性。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ①效果的发动条件判定：当前处于主要阶段，自己场上有至少1只表侧龙族炎属性怪兽，且不存在不是龙族炎属性的怪兽，并且对方场上怪兽数量多于自己。
function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段为主要阶段1或主要阶段2。
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 检查自己场上存在至少1只满足龙族·炎属性·表侧表示的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上不存在不满足龙族·炎属性条件的怪兽，从而保证自己场上的怪兽只有龙族·炎属性怪兽。
		and not Duel.IsExistingMatchingCard(aux.NOT(s.cfilter),tp,LOCATION_MZONE,0,1,nil)
		-- 比较双方场上怪兽数量，确认对方场上的怪兽数量比自己场上的怪兽数量多。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- ①效果处理：跳过当前回合玩家的当前阶段，使主要阶段结束。
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处阶段并保存到局部变量ph中。
	local ph=Duel.GetCurrentPhase()
	-- 让当前回合玩家跳过ph阶段，并将该跳过效果在该阶段结束时重置。
	Duel.SkipPhase(Duel.GetTurnPlayer(),ph,RESET_PHASE+ph,1)
end
-- ②效果的发动条件：本回合累计攻击宣言次数达到3次以上。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己玩家身上id标记数量是否≥3，即本回合攻击宣言次数是否达到3次。
	return Duel.GetFlagEffect(tp,id)>=3
end
-- ②效果的发动目标设定：在满足可抽卡的条件下，将目标玩家设为自己、目标参数设为1，并声明本次操作包含抽卡。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己是否能够进行1张抽卡（chk==0表示发动合法性检查）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁的目标玩家设置为自己，表示抽卡方为自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的目标参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本连锁的处理包含1次抽卡（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 特殊召唤筛选条件：手卡的「天杯龙」系列怪兽，且满足通常的特殊召唤条件与苏生限制。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1aa) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：抽1张卡，若抽卡成功且场上可用怪兽区域有空格，则询问玩家并选择符合条件的「天杯龙」怪兽进行特殊召唤；若受青眼精灵龙效果影响，则可特殊召唤数量上限变为1。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家和目标参数（抽卡玩家和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽相应数量的卡（原因REASON_EFFECT），若实际没有抽到卡则终止后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 获取自己场上可用于特殊召唤的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 确认手卡中存在可特召的「天杯龙」怪兽、有空位且玩家选择进行特殊召唤时才继续。
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 发送选择提示消息，提示玩家从手卡选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡中选择1到可用空格数（ft）张满足spfilter条件的「天杯龙」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
		if g:GetCount()>0 then
			-- 中断当前效果链，使抽卡与特殊召唤成为不同时处理的操作，避免因错失时点导致无法发动后续效果。
			Duel.BreakEffect()
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上（不改变控制者）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

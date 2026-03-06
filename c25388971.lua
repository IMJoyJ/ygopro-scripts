--燦幻開花
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，自己场上的怪兽只有龙族·炎属性怪兽，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这次主要阶段结束。
-- ②：3次以上攻击宣言过的自己·对方回合，把墓地的这张卡除外才能发动。自己抽1张。那之后，可以从手卡把「天杯龙」怪兽任意数量特殊召唤。
local s,id,o=GetID()
-- 注册卡的效果，包括①结束主要阶段和②抽卡并特殊召唤的效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，自己场上的怪兽只有龙族·炎属性怪兽，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这次主要阶段结束。
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
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局攻击宣言时点效果，用于记录攻击次数
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(s.checkop)
		-- 将全局攻击宣言时点效果注册到场上
		Duel.RegisterEffect(ge1,0)
	end
end
-- 记录攻击次数的处理函数
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为当前玩家注册一个标记效果，用于记录攻击次数
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 为对手玩家注册一个标记效果，用于记录攻击次数
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 筛选场上正面表示的龙族炎属性怪兽的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断是否满足①效果发动条件的函数
function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主阶段1或主阶段2
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 判断自己场上是否存在龙族炎属性怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断自己场上是否只有龙族炎属性怪兽
		and not Duel.IsExistingMatchingCard(aux.NOT(s.cfilter),tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方怪兽数量是否多于自己
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 执行①效果的处理函数
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 跳过当前回合玩家的当前阶段
	Duel.SkipPhase(Duel.GetTurnPlayer(),ph,RESET_PHASE+ph,1)
end
-- 判断是否满足②效果发动条件的函数
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家的攻击次数是否达到3次以上
	return Duel.GetFlagEffect(tp,id)>=3
end
-- 设置②效果的目标和操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 筛选手卡中可特殊召唤的天杯龙怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1aa) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行②效果的处理函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 获取当前玩家场上可用的特殊召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检查是否满足特殊召唤条件并询问玩家是否发动
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

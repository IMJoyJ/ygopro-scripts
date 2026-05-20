--ガガガバック
-- 效果：
-- 自己场上的名字带有「我我我」的怪兽被战斗破坏送去墓地的回合才能发动。这个回合被战斗破坏的怪兽尽可能从自己墓地表侧守备表示特殊召唤。那之后，这个效果特殊召唤的怪兽每有1只，自己受到600分伤害。「我我我回归」在1回合只能发动1张。
function c82052602.initial_effect(c)
	-- 自己场上的名字带有「我我我」的怪兽被战斗破坏送去墓地的回合才能发动。这个回合被战斗破坏的怪兽尽可能从自己墓地表侧守备表示特殊召唤。那之后，这个效果特殊召唤的怪兽每有1只，自己受到600分伤害。「我我我回归」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c82052602.condition)
	e1:SetTarget(c82052602.target)
	e1:SetOperation(c82052602.activate)
	c:RegisterEffect(e1)
	if not c82052602.global_check then
		c82052602.global_check=true
		c82052602[0]=false
		c82052602[1]=false
		-- 自己场上的名字带有「我我我」的怪兽被战斗破坏送去墓地的回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(c82052602.checkop)
		-- 注册全局环境效果，用于监测怪兽被战斗破坏的事件
		Duel.RegisterEffect(ge1,0)
		-- 自己场上的名字带有「我我我」的怪兽被战斗破坏送去墓地的回合才能发动。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c82052602.clear)
		-- 注册全局环境效果，在每个回合开始时重置战斗破坏标记
		Duel.RegisterEffect(ge2,0)
	end
end
-- 检查被战斗破坏送去墓地的怪兽是否为自己场上的「我我我」怪兽，并记录该玩家的触发状态
function c82052602.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsSetCard(0x54) and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
			and tc:GetControler()==tc:GetPreviousControler() then
			c82052602[tc:GetControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 重置双方玩家在当前回合是否有「我我我」怪兽被战斗破坏的标记
function c82052602.clear(e,tp,eg,ep,ev,re,r,rp)
	c82052602[0]=false
	c82052602[1]=false
end
-- 过滤本回合被战斗破坏且可以表侧守备表示特殊召唤的怪兽
function c82052602.filter(c,id,e,tp)
	return c:IsReason(REASON_BATTLE) and c:GetTurnID()==id and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查本回合是否有自己场上的「我我我」怪兽被战斗破坏送去墓地，且本回合未发动过同名卡
function c82052602.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足「我我我」怪兽被战斗破坏的条件，且该玩家本回合未发动过「我我我回归」
	return c82052602[tp] and Duel.GetFlagEffect(tp,82052602)==0
end
-- 检查发动条件（自己场上有空位且墓地有符合条件的怪兽），并设置特殊召唤和伤害的操作信息，注册回合发动标记
function c82052602.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只本回合被战斗破坏且可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c82052602.filter,tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount(),e,tp) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
	-- 给发动效果的玩家注册一个持续到回合结束的标识，用于限制同名卡一回合只能发动一张
	Duel.RegisterFlagEffect(tp,82052602,RESET_PHASE+PHASE_END,0,1)
end
-- 效果处理函数：尽可能选择本回合被战斗破坏的怪兽表侧守备表示特殊召唤，之后根据特殊召唤的数量给予自己对应的伤害
function c82052602.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择最多等同于可用怪兽区域数量的、本回合被战斗破坏的怪兽
	local g=Duel.SelectMatchingCard(tp,c82052602.filter,tp,LOCATION_GRAVE,0,ft,ft,nil,Duel.GetTurnCount(),e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 中断当前效果处理，使后续的伤害处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 给予自己等同于特殊召唤怪兽数量乘以600的伤害
		Duel.Damage(tp,g:GetCount()*600,REASON_EFFECT)
	end
end

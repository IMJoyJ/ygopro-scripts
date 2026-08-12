--DPAジャンダムーア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把1只电子界族·4星怪兽效果无效守备表示特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
-- ②：自己的电子界族怪兽用和对方怪兽的战斗给与对方战斗伤害时，把墓地的这张卡除外才能发动。给与对方那个数值的伤害。
local s,id,o=GetID()
-- 注册卡片的初始化效果，设置同调召唤程序并创建两个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把1只电子界族·4星怪兽效果无效守备表示特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己的电子界族怪兽用和对方怪兽的战斗给与对方战斗伤害时，把墓地的这张卡除外才能发动。给与对方那个数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"给予伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 为效果②设置消耗：将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：此卡必须是同调召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选满足条件的墓地4星电子界族怪兽用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动时点处理：判断是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果①的发动信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的处理：从墓地特殊召唤符合条件的怪兽并设置其效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有足够的特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的墓地怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 执行特殊召唤操作并设置被特殊召唤怪兽的效果
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
			-- 设置被特殊召唤怪兽的无效效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 设置被特殊召唤怪兽的无效效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
	-- 设置效果①的后续限制：本回合不能特殊召唤非电子界族怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果，使本回合不能特殊召唤非电子界族怪兽
	Duel.RegisterEffect(e3,tp)
end
-- 限制效果的过滤函数：非电子界族怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 判断战斗中是否有电子界族怪兽参与战斗
function s.cfilter(c,tp)
	local bc=c:GetBattleTarget()
	if not bc then return false end
	return (c:IsRace(RACE_CYBERSE) and c:IsControler(tp) or (bc:IsRace(RACE_CYBERSE) and bc:IsControler(tp))) and c:GetControler()~=bc:GetControler()
end
-- 效果②的发动条件：对方造成战斗伤害且己方有电子界族怪兽参与战斗
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果②的发动时点处理：设置伤害目标和伤害值
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值
	Duel.SetTargetParam(ev)
	-- 设置效果②的发动信息：造成指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 效果②的处理：对目标玩家造成指定数值的伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

--DPAジャンダムーア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把1只电子界族·4星怪兽效果无效守备表示特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
-- ②：自己的电子界族怪兽用和对方怪兽的战斗给与对方战斗伤害时，把墓地的这张卡除外才能发动。给与对方那个数值的伤害。
local s,id,o=GetID()
-- 注册DPA铠装骑兵的同调召唤手续（调整＋调整以外的怪兽1只以上），并注册①和②两个效果：①同调召唤成功时从自己墓地特殊召唤1只电子界族·4星怪兽并使其效果无效，且本回合自己不能特殊召唤电子界族以外的怪兽；②自己电子界族怪兽与对方怪兽战斗造成战斗伤害时，除外墓地中的这张卡，给与对方那个数值的伤害；两个效果分别1回合1次。
function s.initial_effect(c)
	-- 将这张卡设定为同调怪兽，素材要求为“调整＋调整以外的怪兽1只以上”：任意调整1只、任意调整以外的怪兽1只以上（minc=1，maxc默认99）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应①效果原文：“①：这张卡同调召唤的场合才能发动。从自己墓地把1只电子界族·4星怪兽效果无效守备表示特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。”
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
	-- 对应②效果原文：“②：自己的电子界族怪兽用和对方怪兽的战斗给与对方战斗伤害时，把墓地的这张卡除外才能发动。给与对方那个数值的伤害。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"给予伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为“把墓地的这张卡除外”（aux.bfgcost在chk时检查自身可除外，发动时从墓地除外这张卡）。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡以同调召唤方式特殊召唤成功（IsSummonType(SUMMON_TYPE_SYNCHRO)）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 特殊召唤对象的筛选条件：从自己墓地选择1只等级4、电子界族、可以进行特殊召唤的怪兽，以表侧守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动合法检查：自己场上存在可用怪兽区，且墓地存在满足s.spfilter的电子界族·4星怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动合法性检查阶段）时确认自己场上是否有可用怪兽区（Duel.GetLocationCount>0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己墓地至少有1只符合条件的电子界族·4星怪兽可供特殊召唤（IsExistingMatchingCard）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果属于特殊召唤，预计从自己墓地特殊召唤1只怪兽（目标参数为LOCATION_GRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：若自己场上仍有可用怪兽区，则从墓地选择1只符合条件的电子界族·4星怪兽以表侧守备表示特殊召唤；特殊召唤成功后对其附加效果无效处理（EFFECT_DISABLE与EFFECT_DISABLE_EFFECT）；随后给自己玩家附加本回合不能特殊召唤电子界族以外怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理特殊召唤前再次确认自己场上仍有可用怪兽区，防止场地变化导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家显示选择提示，提示从墓地选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1张满足s.spfilter条件的怪兽作为特殊召唤对象（处理时选卡）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选择的怪兽以表侧守备表示特殊召唤；若特殊召唤成功（返回值非0），则继续执行后续无效化处理。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
			-- 对应原文“效果无效”中的状态无效：给该怪兽附加EFFECT_TYPE_SINGLE的EFFECT_DISABLE效果，使其在场上期间怪兽效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对应原文“效果无效”中的效果无效化：给该怪兽附加EFFECT_DISABLE_EFFECT效果，使其效果本身无效（离场后仍保持无效状态），从而与EFFECT_DISABLE共同实现“效果无效”。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 特殊召唤处理完成后调用SpecialSummonComplete()，以触发特殊召唤成功时点时点的各种诱发效果。
			Duel.SpecialSummonComplete()
		end
	end
	-- 对应①效果后半句“这个回合，自己不是电子界族怪兽不能特殊召唤。”以及②效果原文“②：自己的电子界族怪兽用和对方怪兽的战斗给与对方战斗伤害时，把墓地的这张卡除外才能发动。给与对方那个数值的伤害。”；代码中定义了自肃效果及②效果所需的过滤/条件/目标/操作函数。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（不能特殊召唤非电子界族怪兽）注册给当前操作玩家tp，持续到这个回合结束（RESET_PHASE+PHASE_END）。
	Duel.RegisterEffect(e3,tp)
end
-- 自肃效果的过滤函数：只要怪兽不是电子界族（RACE_CYBERSE），就不允许被特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- ②效果战斗伤害事件的过滤函数：判断战斗关联的两只怪兽中是否存在己方（tp）场上的电子界族怪兽，且战斗双方的控制者不同（即该电子界族怪兽在与对方怪兽战斗）。具体逻辑：c为事件中的一只怪兽，bc为其战斗对象；若（c是电子界族且控制者为tp）或（bc是电子界族且控制者为tp），并且c和bc控制者不同，则通过。
function s.cfilter(c,tp)
	local bc=c:GetBattleTarget()
	if not bc then return false end
	return (c:IsRace(RACE_CYBERSE) and c:IsControler(tp) or (bc:IsRace(RACE_CYBERSE) and bc:IsControler(tp))) and c:GetControler()~=bc:GetControler()
end
-- ②效果的发动条件：受到战斗伤害的一方是对方（ep~=tp），且战斗伤害事件中存在满足cfilter的怪兽组合（说明己方电子界族怪兽与对方怪兽战斗造成了战斗伤害）。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果发动时的目标处理：可以发动则返回true；将目标玩家设为对方，伤害参数设为本次战斗伤害值ev，并登记伤害类操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为本次战斗伤害的数值ev，作为后续造成伤害的数值。
	Duel.SetTargetParam(ev)
	-- 设置操作信息：本次效果会给对方玩家造成ev点伤害（CATEGORY_DAMAGE），对象参数用于伤害检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- ②效果处理：从连锁信息中取得目标玩家和伤害数值，执行实际伤害处理。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家p和伤害参数d（即之前SetTargetPlayer/SetTargetParam设置的对方和战斗伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式（REASON_EFFECT）给对方玩家p造成d点生命值伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

--チューン・ナイト
-- 效果：
-- ①：这张卡特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
function c38783169.initial_effect(c)
	-- 全局启用“从额外卡组特殊召唤次数限制”的计数系统，为后续实现该卡自肃所需的额外卡组特召次数统计提供支持。
	aux.EnableExtraDeckSummonCountLimit()
	-- 为该卡注册同盟怪兽通用效果（可装备给自己场上的表侧表示怪兽、代替装备怪兽被战斗/效果破坏、以及解除装备时特殊召唤），装备对象过滤条件使用aux.TRUE。
	aux.EnableUnionAttribute(c,aux.TRUE)
	-- 对应①：这张卡特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38783169,0))  --"这张卡当作调整使用"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c38783169.tntg)
	e1:SetOperation(c38783169.tnop)
	c:RegisterEffect(e1)
end
c38783169.treat_itself_tuner=true
-- 效果①的发动条件判断：仅当此卡当前不是调整怪兽时才允许发动，因为若已是调整则“当作调整使用”没有意义。
function c38783169.tntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsType(TYPE_TUNER) end
end
-- 效果①的处理：若此卡仍表侧且在场上且与该效果关联，则赋予其“本回合当作调整使用”的效果；随后为发动者附加“直至回合结束时最多只能有1次从额外卡组特殊召唤”的自肃，并注册持续计数效果来统计额外卡组特召次数。
function c38783169.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 对应效果原文：“这个回合，这张卡当作调整使用。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 对应效果原文：“这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38783169.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“从额外卡组不能特殊召唤（超过剩余次数时）”的限制效果e1注册给当前玩家tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 对应效果原文：“这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c38783169.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册持续监测特殊召唤成功事件的辅助效果e2，每当有从额外卡组的特殊召唤成功时，自动减少对应玩家的可特召次数。
	Duel.RegisterEffect(e2,tp)
	-- 对应效果原文：“这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将记录/标记效果e3注册给当前玩家tp，用于标识本回合已发动过该自肃（或配合计数系统进行限制判定）。
	Duel.RegisterEffect(e3,tp)
end
-- 自肃限制的过滤函数：当被特殊召唤的怪兽来自额外卡组，且召唤玩家sump的额外卡组可特召剩余次数已为0时，禁止该特殊召唤。
function c38783169.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 判定条件：怪兽位于额外卡组（即从额外卡组进行特殊召唤）且召唤玩家sump的剩余可特召次数不大于0。
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 筛选函数：判断一只怪兽是否为“由玩家tp从额外卡组特殊召唤成功”（召唤玩家为tp且先前位置是额外卡组），用于识别本次特殊召唤是否消耗额外卡组特召次数。
function c38783169.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 持续效果处理函数：按双方分别检查本次特殊召唤成功的怪兽中是否含有从额外卡组特殊召唤的怪兽，若有则将该召唤玩家的额外卡组特召剩余次数减一，以实现本回合只能再进行有限次额外卡组特殊召唤的限制。
function c38783169.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c38783169.cfilter,1,nil,tp) then
		-- 将当前玩家tp的额外卡组特召剩余次数减1，表示已用掉一次额外卡组特殊召唤机会。
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(c38783169.cfilter,1,nil,1-tp) then
		-- 将对方玩家1-tp的额外卡组特召剩余次数减1（计数系统会记录对方的额外卡组特召行为，但对方是否实际受该自肃限制由对应的限制效果决定）。
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end

--アドバンス・ディボーター
-- 效果：
-- 这张卡不用这张卡的效果不能特殊召唤。把这张卡解放作上级召唤成功的场合，下次的自己的准备阶段时才能发动。这张卡从墓地特殊召唤。这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。
function c59951714.initial_effect(c)
	-- 这张卡不用这张卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把这张卡解放作上级召唤成功的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetOperation(c59951714.spr)
	c:RegisterEffect(e2)
	-- 下次的自己的准备阶段时才能发动。这张卡从墓地特殊召唤。这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59951714,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c59951714.spcon)
	e3:SetCost(c59951714.spcost)
	e3:SetTarget(c59951714.sptg)
	e3:SetOperation(c59951714.spop)
	c:RegisterEffect(e3)
	-- 注册一个特殊召唤活动计数器，用于记录本回合自己从额外卡组特殊召唤的次数，以配合发动限制。
	Duel.AddCustomActivityCounter(59951714,ACTIVITY_SPSUMMON,c59951714.counterfilter)
end
-- 计数器过滤函数：当被特殊召唤的怪兽来自额外卡组时返回false（计数+1），否则返回true（不计数），从而只记录额外卡组特殊召唤。
function c59951714.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 当这张卡作为上级召唤的解放被送去墓地时，给自身放置一个标记，表示已经解放过了。
function c59951714.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if r==REASON_SUMMON then
		c:RegisterFlagEffect(59951714,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判定墓地效果能否发动：这张卡不是在本回合被送去墓地，且当前为持有者的准备阶段，且带有解放标记。
function c59951714.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 具体条件：这张卡被送去墓地的回合不是当前回合（即下次），当前回合玩家是自己（准备阶段），且自身存在解放标记。
	return c:GetTurnID()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(59951714)>0
end
-- 发动代价（cost）：若本回合自己尚未从额外卡组特殊召唤过则满足，随后给自己附加直到回合结束的不能从额外卡组特殊召唤效果。
function c59951714.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价：通过自定义计数器确认本回合自己从额外卡组特殊召唤的次数为0，即尚未进行过额外卡组特殊召唤。
	if chk==0 then return Duel.GetCustomActivityCount(59951714,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡从墓地特殊召唤。这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59951714.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤的制约效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制对象判断：位于额外卡组的怪兽返回true，从而禁止从额外卡组特殊召唤任何怪兽。
function c59951714.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 特殊召唤发动条件：自己怪兽区域有空位，且这张卡可以被特殊召唤。
function c59951714.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 将本次处理信息设为特殊召唤这张卡，数量为1，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(59951714)
end
-- 效果处理时，若这张卡仍与效果相关，则执行特殊召唤。
function c59951714.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到持有者场上，无视召唤条件，但仍需满足苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end

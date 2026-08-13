--嗤う黒山羊
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：宣言1个怪兽卡名才能发动。这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽从墓地以外特殊召唤。
-- ②：把墓地的这张卡除外，宣言1个怪兽卡名才能发动。这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽的场上发动的效果发动。
local s,id,o=GetID()
-- 给这张卡注册两个效果：e1对应①的发动效果（魔法·陷阱卡的发动，可自由时点，宣言怪兽卡名后本回合禁止双方从墓地以外特殊召唤原本卡名相同的怪兽）；e2对应②的墓地效果（在墓地可作二速发动，除外自身为cost，宣言怪兽卡名后禁止双方发动原本卡名相同的怪兽在场上发动的效果）。两个效果共用1次发动次数，实现“这个卡名的①②的效果1回合只能有1次使用其中任意1个。”
function s.initial_effect(c)
	-- ①：宣言1个怪兽卡名才能发动。这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽从墓地以外特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ANNOUNCE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，宣言1个怪兽卡名才能发动。这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽的场上发动的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ANNOUNCE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置②效果的发动COST：将位于墓地的这张卡自身除外（对应原文“把墓地的这张卡除外”）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.alop)
	c:RegisterEffect(e2)
end
-- ①②共用的发动前处理：先判定可以发动（chk==0直接返回true），然后提示玩家宣言一个怪兽卡名，用Duel.AnnounceCard取得宣言的卡号并存入当前连锁的目标参数，最后写入操作信息CATEGORY_ANNOUNCE，以便后续处理时获取。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向当前玩家发送“请宣言一个卡名”的选择提示消息，用于配合Duel.AnnounceCard进行卡名宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE}
	-- 让当前玩家宣言一张怪兽卡的卡名（通过announce_filter限定为怪兽类型），返回宣言的卡号并赋值给ac。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号ac保存为当前连锁的目标参数，供效果处理阶段用Duel.GetChainInfo读取。
	Duel.SetTargetParam(ac)
	-- 设置本次连锁的操作信息为CATEGORY_ANNOUNCE（宣言卡名类效果），目标为空、数量为0，供其他效果或规则检测。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- ①效果处理：从当前连锁读取宣言的卡号，创建一个持续到结束阶段、影响双方的场地效果，禁止任何玩家从墓地以外把原本卡名等于宣言卡名的怪兽特殊召唤，并将该效果注册到场上。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出之前保存的宣言卡号（即目标参数）。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- ①：这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽从墓地以外特殊召唤。②：这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽的场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetLabel(ac)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止特殊召唤的限制效果正式登记到当前玩家tp侧（因SetTargetRange(1,1)而同时限制双方），持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定函数：当有怪兽要被特殊召唤时，若其原本卡名等于宣言卡名e:GetLabel()，且其当前不在墓地（即不是从墓地特殊召唤），则禁止该特殊召唤。
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsOriginalCodeRule(e:GetLabel()) and not c:IsLocation(LOCATION_GRAVE)
end
-- ②效果处理：从当前连锁读取宣言的卡号，创建一个持续到结束阶段、影响双方的场地效果，禁止双方发动“原本卡名等于宣言卡名的怪兽在场上发动的效果”（通过s.actlimit判定具体效果），并注册该效果。
function s.alop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出之前保存的宣言卡号（即目标参数）。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- ②：这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽的场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetLabel(ac)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止发动效果的限制效果正式登记到当前玩家tp侧（因SetTargetRange(1,1)而同时限制双方），持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定函数：当某个效果re要被发动时，若其发动者是原本卡名等于宣言卡名e:GetLabel()的怪兽，且该效果的发动位置在场上怪兽区域（LOCATION_MZONE），且该效果是怪兽效果，则禁止该效果发动。
function s.actlimit(e,re,tp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel()) and re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)
end

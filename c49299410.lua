--嗤う黒山羊
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：宣言1个怪兽卡名才能发动。这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽从墓地以外特殊召唤。
-- ②：把墓地的这张卡除外，宣言1个怪兽卡名才能发动。这个回合，双方不能把原本卡名和宣言的怪兽相同的怪兽的场上发动的效果发动。
local s,id,o=GetID()
-- 注册两个效果，一个为通常效果，一个为墓地发动的诱发效果
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
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.alop)
	c:RegisterEffect(e2)
end
-- 选择宣言卡名并设置目标参数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE}
	-- 让玩家宣言一个怪兽卡
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号设为连锁参数
	Duel.SetTargetParam(ac)
	-- 设置发动信息，用于检测效果是否正确发动
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 处理①效果：禁止特殊召唤相同卡名的怪兽
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中设定的目标参数（即宣言的卡号）
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 创建并注册禁止特殊召唤的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetLabel(ac)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：若怪兽原本卡号与宣言卡号相同且不在墓地，则不能特殊召唤
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsOriginalCodeRule(e:GetLabel()) and not c:IsLocation(LOCATION_GRAVE)
end
-- 处理②效果：禁止发动相同卡名的场上怪兽效果
function s.alop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中设定的目标参数（即宣言的卡号）
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 创建并注册禁止发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetLabel(ac)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：若效果来源为宣言卡号的怪兽且在场上发动，则不能发动
function s.actlimit(e,re,tp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel()) and re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)
end

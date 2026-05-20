--閃刀姫－カメリア
-- 效果：
-- 效果怪兽2只
-- 这张卡不用连接召唤不能从额外卡组特殊召唤，自己对「闪刀姬-卡米丽娅」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己墓地的魔法卡是3张以下的场合才能发动。从卡组把1张「闪刀」卡送去墓地。
-- ②：这张卡被送去墓地的场合，以对方场上1只怪兽为对象才能发动。这张卡在对方场上特殊召唤，作为对象的怪兽送去墓地。这张卡的控制权在这个回合的结束阶段回归原本持有者。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含召唤限制、连接召唤手续、以及两个效果的注册。
function s.initial_effect(c)
	-- 开启全局洗脑解除标记检查，用于处理控制权回归原本持有者的效果。
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	-- 添加连接召唤手续：效果怪兽2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- 这张卡不用连接召唤不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤限制为只能通过连接召唤从额外卡组特殊召唤。
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己墓地的魔法卡是3张以下的场合才能发动。从卡组把1张「闪刀」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以对方场上1只怪兽为对象才能发动。这张卡在对方场上特殊召唤，作为对象的怪兽送去墓地。这张卡的控制权在这个回合的结束阶段回归原本持有者。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数：自己墓地的魔法卡在3张以下。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在4张或以上的魔法卡（若不存在，则说明是3张以下）。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,4,nil,TYPE_SPELL)
end
-- 过滤卡组中「闪刀」卡片且能送去墓地的过滤函数。
function s.filter(c)
	return c:IsSetCard(0x115) and c:IsAbleToGrave()
end
-- 效果①的发动准备与合法性检测函数（Target）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张可以送去墓地的「闪刀」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：将卡片送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数（Operation）：从卡组选择1张「闪刀」卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「闪刀」卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡因效果送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 效果②的发动准备与对象选择函数（Target）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToGrave() end
	local c=e:GetHandler()
	-- 检查对方场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		-- 检查对方场上是否存在至少1只可以送去墓地的怪兽。
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡（作为效果②的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只可以送去墓地的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：将自身特殊召唤到对方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁处理的操作信息：将作为对象的怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的效果处理函数（Operation）：特殊召唤自身，将对象怪兽送去墓地，并注册回合结束时控制权回归的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与连锁相关，并尝试将自身特殊召唤到对方场上，若失败则结束处理。
	if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)==0 then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 这张卡的控制权在这个回合的结束阶段回归原本持有者。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将控制权回归的延迟效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与连锁相关，则将其因效果送去墓地。
	if tc:IsRelateToChain() then Duel.SendtoGrave(tc,REASON_EFFECT) end
end
-- 控制权回归效果的发动条件判定函数：检查自身是否带有特定的标记。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)>0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 控制权回归效果的处理函数：通过注册洗脑解除效果强制让控制权回归原本持有者。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的控制权在这个回合的结束阶段回归原本持有者。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabelObject(c)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.rettg)
	-- 注册洗脑解除效果以强制重置控制权。
	Duel.RegisterEffect(e1,tp)
	-- 立即刷新场上卡片状态，使控制权变更立即生效。
	Duel.AdjustAll()
	c:ResetFlagEffect(id)
	e1:Reset()
end
-- 洗脑解除效果的目标过滤函数：仅对带有特定标记的这张卡自身生效。
function s.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(id)>0
end

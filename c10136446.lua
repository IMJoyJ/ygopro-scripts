--黄昏の堕天使ルシファー
-- 效果：
-- 6星以上的天使族·暗属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「堕天使」魔法卡和1张「堕天使」陷阱卡在自己场上盖放。
-- ②：对方不能把场上的这张卡作为效果的对象。
-- ③：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
local s,id,o=GetID()
-- 定义卡片的初始化效果函数，用于注册该卡的所有效果。
function s.initial_effect(c)
	-- 为该卡添加融合召唤手续，要求2只暗属性、天使族、等级6以上的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	c:EnableReviveLimit()
	-- 这张卡融合召唤的场合才能发动。从卡组把1张「堕天使」魔法卡和1张「堕天使」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 对方不能把场上的这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	-- 设置效果的值为aux.tgoval，使该卡不能成为对方效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cpcost)
	e3:SetTarget(s.cptg)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)
end
-- 定义融合素材过滤函数，要求卡片为暗属性、天使族、等级6以上。
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY) and c:IsLevelAbove(6)
end
-- 设置①效果的发动条件，必须通过融合召唤成功才能触发。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义卡组中可盖放的堕天使魔法·陷阱卡的过滤函数。
function s.setfilter(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 定义选择检查函数，确保选中的2张卡中至少包含1张魔法和1张陷阱。
function s.gcheck(sg,tp)
	return sg:IsExists(s.setfilter1,1,nil,tp) and sg:IsExists(s.setfilter2,1,nil,tp)
end
-- 定义①效果中魔法卡的过滤条件：堕天使魔法、可盖放，且场上至少有2个空位或为场地图。
function s.setfilter1(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL) and c:IsSSetable()
		-- 检查场上有2个以上空位（允许同时盖放魔法和陷阱）。
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 或者场上有至少1个空位且该卡是场地图时可盖放。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsType(TYPE_FIELD))
end
-- 定义①效果中陷阱卡的过滤条件：堕天使陷阱且可盖放。
function s.setfilter2(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的目标函数，检查卡组中是否存在满足条件的魔法和陷阱各至少1张。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合可盖放条件的堕天使魔法·陷阱卡。
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return sg:CheckSubGroup(s.gcheck,2,2,tp) end
end
-- ①效果的发动处理函数，执行将选中的魔法和陷阱卡盖放到场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取卡组中可盖放的堕天使魔法·陷阱卡，用于实际盖放。
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,tp)
	if not sg:CheckSubGroup(s.gcheck,2,2,tp) then return end
	-- 向玩家发送选择提示信息，告知其选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=sg:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	if g:GetCount()==2 then
		-- 将玩家选择的卡盖放到自己的魔法陷阱区。
		Duel.SSet(tp,g)
	end
end
-- ③效果的代价函数，支付1000点基本分。
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家是否能够支付1000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 执行支付1000点基本分。
	Duel.PayLPCost(tp,1000)
end
-- 定义③效果的目标过滤函数，筛选墓地中可用的堕天使魔法·陷阱卡。
function s.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- ③效果的目标函数，确定要选取的墓地卡并准备激活其效果。
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检测是否存在符合条件的墓地卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择目标提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 让玩家从墓地中选择1张符合条件的目标卡。
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前效果的目标卡，以防误将目标卡视为连锁对象。
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，使该效果不可被响应。
	Duel.ClearOperationInfo(0)
	-- 设置操作信息，声明本回合将把目标卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ③效果的处理函数，执行目标卡的效果并将其返回卡组。
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToChain() then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 打断当前连锁，使目标卡的效果能够立即处理。
	Duel.BreakEffect()
	-- 将目标卡洗入卡组。
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

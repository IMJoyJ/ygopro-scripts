--黄昏の堕天使ルシファー
-- 效果：
-- 6星以上的天使族·暗属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「堕天使」魔法卡和1张「堕天使」陷阱卡在自己场上盖放。
-- ②：对方不能把场上的这张卡作为效果的对象。
-- ③：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
local s,id,o=GetID()
-- 初始化并注册「黄昏之堕天使 路西法」的融合召唤手续与各项效果
function s.initial_effect(c)
	-- 设定融合素材：6星以上的天使族·暗属性怪兽×2
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「堕天使」魔法卡和1张「堕天使」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：对方不能把场上的这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	-- 设置抗性：对方不能把这张卡作为效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"复制效果"
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
-- 融合素材过滤条件：6星以上的天使族·暗属性怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY) and c:IsLevelAbove(6)
end
-- 判断此卡是否是通过融合召唤的形式特殊召唤成功
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤条件：卡组中的「堕天使」系列魔法·陷阱卡且能在场上盖放
function s.setfilter(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 检查选择的两张卡中是否包含1张魔法卡和1张陷阱卡
function s.gcheck(sg,tp)
	return sg:IsExists(s.setfilter1,1,nil,tp) and sg:IsExists(s.setfilter2,1,nil,tp)
end
-- 过滤条件：包含「堕天使」魔法卡且可以在场上盖放
function s.setfilter1(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL) and c:IsSSetable()
		-- 自己场上的魔法与陷阱区域有2个以上的空位
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 自己场上的魔法与陷阱区域有1个以上的空位且盖放的卡为场地魔法卡
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsType(TYPE_FIELD))
end
-- 过滤条件：包含「堕天使」陷阱卡且可以在场上盖放
function s.setfilter2(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 检测卡组中是否存在可以盖放的1张「堕天使」魔法卡和1张「堕天使」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从卡组中获取所有满足过滤条件的卡片
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return sg:CheckSubGroup(s.gcheck,2,2,tp) end
end
-- 从卡组将1张「堕天使」魔法卡和1张「堕天使」陷阱卡在场上盖放的效果处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取所有满足过滤条件的卡片
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,tp)
	if not sg:CheckSubGroup(s.gcheck,2,2,tp) then return end
	-- 提示玩家选择需要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local g=sg:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	if g:GetCount()==2 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- 支付1000基本分的发动代价检测与处理
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：自己墓地中可以回到卡组且能够被复制并适用的「堕天使」魔法·陷阱卡
function s.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 以自己墓地1张「堕天使」魔法·陷阱卡为对象发动效果的检测与设置
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检测自己墓地中是否存在满足过滤条件的「堕天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要成为效果对象的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1张满足过滤条件的「堕天使」魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前效果的对象
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，以防被无效或响应
	Duel.ClearOperationInfo(0)
	-- 设置操作信息：包含对象卡回到卡组的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 复制并适用目标魔法·陷阱卡效果并将其送回卡组的效果处理
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToChain() then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果，使效果不是同时处理
	Duel.BreakEffect()
	-- 将适用的卡洗回持有者的卡组
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

--黄昏の堕天使ルシファー
-- 效果：
-- 6星以上的天使族·暗属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「堕天使」魔法卡和1张「堕天使」陷阱卡在自己场上盖放。
-- ②：对方不能把场上的这张卡作为效果的对象。
-- ③：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
local s,id,o=GetID()
-- 设置融合召唤手续及怪兽效果
function s.initial_effect(c)
	-- 添加融合召唤手续：需2只满足条件的怪兽作为融合素材
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
	-- 设置抗性：不能成为对方卡片效果的对象
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
-- 融合素材过滤：6星以上的天使族·暗属性怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY) and c:IsLevelAbove(6)
end
-- 触发条件：检查自身是否融合召唤成功
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 卡片过滤：卡组中可盖放的「堕天使」魔法·陷阱卡
function s.setfilter(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 组合检查：所选卡片组中必须包含至少1张「堕天使」魔法卡和1张「堕天使」陷阱卡
function s.gcheck(sg,tp)
	return sg:IsExists(s.setfilter1,1,nil,tp) and sg:IsExists(s.setfilter2,1,nil,tp)
end
-- 卡片过滤：魔陷区有足够空位时可盖放的「堕天使」魔法卡
function s.setfilter1(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL) and c:IsSSetable()
		-- 检查自身魔陷区空位是否大于1（同时盖放非场地魔法与陷阱卡需2个空位）
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 若盖放的是场地魔法卡，则只需魔陷区空位大于0
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsType(TYPE_FIELD))
end
-- 卡片过滤：可盖放的「堕天使」陷阱卡
function s.setfilter2(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 目标检查：检查卡组中是否存在满足条件的1张「堕天使」魔法卡和1张「堕天使」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有可盖放的「堕天使」魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return sg:CheckSubGroup(s.gcheck,2,2,tp) end
end
-- 效果处理：从卡组选1张「堕天使」魔法卡和1张「堕天使」陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有可盖放的「堕天使」魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,tp)
	if not sg:CheckSubGroup(s.gcheck,2,2,tp) then return end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local g=sg:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	if g then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- 发动代价：支付1000基本分
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身基本分是否足够支付1000LP
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000点基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 对象过滤：墓地中可回到卡组且能适用发动效果的「堕天使」魔法·陷阱卡
function s.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 目标选择：以自己墓地1张「堕天使」魔法·陷阱卡为对象，获取并复制其效果，设置回卡组的操作信息
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查自己墓地是否存在可作为对象的「堕天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1张「堕天使」魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁的对象卡片（避免原卡片被视作直接取对象发动）
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，以重新设置本效果的操作信息
	Duel.ClearOperationInfo(0)
	-- 设置效果处理的操作信息：将对象卡片回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：适用目标魔法·陷阱卡发动时的效果，之后将该卡回到卡组
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToChain() then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果，使复制效果的处理与后续回到卡组视为不同时进行
	Duel.BreakEffect()
	-- 将目标魔法·陷阱卡洗回卡组
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

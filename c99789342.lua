--黒魔術のカーテン
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
-- ①：把基本分支付一半才能发动。从卡组把1只「黑魔术师」特殊召唤。
function c99789342.initial_effect(c)
	-- 将「黑魔术师」（卡号46986414）登记为此卡代码列表中记载的卡名，用于关联检索/判定等场合。
	aux.AddCodeList(c,46986414)
	-- ①：把基本分支付一半才能发动。从卡组把1只「黑魔术师」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c99789342.cost)
	e1:SetTarget(c99789342.target)
	e1:SetOperation(c99789342.activate)
	c:RegisterEffect(e1)
end
-- cost函数：在发动合法性检查时，确认本回合尚未进行过任何召唤·反转召唤·特殊召唤，并作为发动时点的自肃条件。
function c99789342.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查（chk==0）时，要求本回合通常召唤（含放置）次数为0。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 同时要求本回合反转召唤次数和特殊召唤次数均为0，即本回合未进行过任何召唤·反转召唤·特殊召唤才能发动。
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 支付基本分的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。（此处实现其中的特殊召唤限制）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c99789342.sumlimit)
	-- 将“不能特殊召唤”的誓约效果注册给当前玩家，回合结束前有效。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。①：把基本分支付一半才能发动。从卡组把1只「黑魔术师」特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 将“不能召唤”的誓约效果注册给当前玩家，回合结束前有效。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 将“不能反转召唤”的誓约效果注册给当前玩家，回合结束前有效。
	Duel.RegisterEffect(e3,tp)
end
-- sumlimit函数：只有来自「黑魔术的幕帘」自身效果的特殊召唤被允许，其他效果发起的特殊召唤都因自肃被禁止。
function c99789342.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetHandler()~=se:GetHandler()
end
-- filter函数：筛选卡组中卡号46986414（「黑魔术师」）且能够被特殊召唤的怪兽。
function c99789342.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数：发动时检查场上是否有空位且卡组存在符合条件的「黑魔术师」，满足才可发动。
function c99789342.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查时，要求自己的主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动检查时，要求卡组中至少存在1只符合条件的「黑魔术师」可作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c99789342.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置操作信息：本次效果属于特殊召唤，处理时从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- activate函数：效果处理时若怪兽区有空位，则从卡组选择1只「黑魔术师」以表侧表示特殊召唤。
function c99789342.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己的主要怪兽区没有空位，则效果不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发出选择要特殊召唤的卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足过滤条件的「黑魔术师」（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c99789342.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「黑魔术师」以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--金神の戦鬼 アカスナ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
-- ②：自己·对方的主要阶段，从自己的手卡·场上（里侧表示）把1张陷阱卡送去墓地才能发动。对方场上的表侧表示怪兽全部变成里侧守备表示。
-- ③：自己结束阶段才能发动。从卡组把1张「艮神鬼」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：注册①的手卡特殊召唤规则效果（1回合1次誓约限制）、②的双方主要阶段二速把对方场上怪兽全部变成里侧守备表示的诱发即时效果、③的自己结束阶段从卡组盖放「艮神鬼」陷阱卡的诱发选发效果
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，从自己的手卡·场上（里侧表示）把1张陷阱卡送去墓地才能发动。对方场上的表侧表示怪兽全部变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成里侧表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段才能发动。从卡组把1张「艮神鬼」陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon2)
	e3:SetTarget(s.settg2)
	e3:SetOperation(s.setop2)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件的过滤函数：卡须为里侧表示、能作为代价回到手卡或额外卡组，且该卡离场后自己场上仍有可用的怪兽区
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 检查该卡离场后自己场上是否还有1个以上可用的怪兽区（用于腾出特殊召唤的格子）
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①的特殊召唤条件：自己场上存在1张以上满足条件的里侧表示卡（能回到手卡·额外卡组且离场后有空怪兽区）
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1张满足过滤条件的里侧表示卡
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- ①特殊召唤的目标选择：从自己场上满足条件的里侧表示卡中选择1张，作为要回到手卡·额外卡组的卡保存到标签对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上所有满足条件的里侧表示卡（能回到手卡·额外卡组且离场后有空怪兽区）
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 向玩家提示：请选择要回到手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①特殊召唤的处理：将选中的里侧表示卡给对方观看（确认），再让其回到持有者的手卡·额外卡组，之后这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选中的里侧表示卡给对方玩家确认（给对方观看）
	Duel.ConfirmCards(1-tp,g)
	-- 以特殊召唤手续的原因把选中的卡送回持有者的手卡（额外怪兽则回到额外卡组）
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果的发动条件：当前处于自己或对方的主要阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- ②效果代价的过滤函数：位于手卡或者里侧表示的、能作为代价送去墓地的陷阱卡
function s.tgfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFacedown())
		and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- ②效果的代价处理：确认存在可作为代价的陷阱卡后，让玩家从自己的手卡·场上（里侧表示）选1张陷阱卡送去墓地
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·场上是否存在至少1张可作为代价送去墓地的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·场上（里侧表示）选择1张满足条件的陷阱卡作为代价
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 把选择的陷阱卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果对象的过滤函数：表侧表示且可以变成里侧守备表示的怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的目标设定：确认对方场上存在可变成里侧守备表示的表侧表示怪兽，并把对方场上全部这类怪兽登记为改变表示形式的操作对象
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且可变成里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上所有表侧表示且可变成里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：宣告将对方场上全部表侧表示怪兽作为改变表示形式效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的处理：重新取得对方场上所有表侧表示怪兽，把它们全部变成里侧守备表示
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新取得对方场上所有表侧表示且可变成里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 把对方场上的表侧表示怪兽全部变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- ③效果的发动条件：当前回合玩家是自己（即自己的结束阶段）
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- ③效果对象的过滤函数：卡名带有「艮神鬼」字段（系列号0x1e4）、能在自己场上盖放的陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1e4) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的目标设定：确认卡组中存在至少1张可盖放的「艮神鬼」陷阱卡
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可盖放的「艮神鬼」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ③效果的处理：让玩家从卡组选择1张「艮神鬼」陷阱卡，在自己场上盖放
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「艮神鬼」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的「艮神鬼」陷阱卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end

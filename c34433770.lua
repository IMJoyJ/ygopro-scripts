--閃刀亜式－レムニスゲート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的「闪刀姬」怪兽和「闪刀」魔法卡各相同数量为对象才能发动。那些卡回到卡组。那之后，可以让回去的卡每3张最多1张的场上的卡回到手卡。
-- ②：这张卡在墓地存在的状态，自己场上有「闪刀」怪兽特殊召唤的场合，把这张卡除外才能发动。进行1只「闪刀姬」连接怪兽的连接召唤。
local s,id,o=GetID()
-- 初始化效果注册函数。
function s.initial_effect(c)
	-- ①：以自己墓地的「闪刀姬」怪兽和「闪刀」魔法卡各相同数量为对象才能发动。那些卡回到卡组。那之后，可以让回去的卡每3张最多1张的场上的卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 为卡片在墓地被特殊召唤时注册一个延迟合并的触发事件（用于效果②的触发条件监听）。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ②：这张卡在墓地存在的状态，自己场上有「闪刀」怪兽特殊召唤的场合，把这张卡除外才能发动。进行1只「闪刀姬」连接怪兽的连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置效果②的发动代价为将这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，筛选自己墓地中可被效果选择为对象的「闪刀」魔法卡。
function s.sfilter(c,e)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x115) and (not e or c:IsCanBeEffectTarget(e))
end
-- 过滤函数，筛选自己墓地中可被效果选择为对象的「闪刀姬」怪兽。
function s.mfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1115) and (not e or c:IsCanBeEffectTarget(e))
end
-- 效果①的发动目标处理，选择墓地相同数量的「闪刀」魔法卡和「闪刀姬」怪兽为对象，并注册返回卡组的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有满足条件的「闪刀」魔法卡卡片组。
	local g1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取自己墓地中所有满足条件的「闪刀姬」怪兽卡片组。
	local g2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g1:GetCount()>0 and g2:GetCount()>0 end
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家分别从两个卡组中选择各相同数量的卡片进行组合。
	local tg=aux.SelectSameCount(tp,g1,g2)
	-- 将玩家选择的目标卡片组设为当前连锁的广义对象卡片。
	Duel.SetTargetCard(tg)
	-- 设置操作信息：将这些选中的卡片送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
end
-- 效果①的具体处理逻辑，使选中的卡片回到卡组。那之后，根据回去卡片数量折算并让场上相应数量的卡回到手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中依然与效果存在关联的所有对象卡片组。
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 将关联的对象卡片送回卡组并洗牌。若有卡片成功送回卡组，则获取具体被成功送回卡组的卡片组以准备后续处理。
	if sg:GetCount()>0 and Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 获取先前实际上移回卡组（包含额外卡组）的卡片数量。
		local g=Duel.GetOperatedGroup()
		local ct=math.floor(g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)/3)
		-- 获取场上所有可以作为回到手牌效果对象的目标卡片。
		local dg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 若实际移回卡组折算的额度大于0、场上存在可弹回卡片，且玩家选择执行弹卡效果，则继续处理。
		if ct>0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选卡返回手卡？"
			-- 提示玩家选择要弹回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			local dc=dg:Select(tp,1,ct,nil)
			if dc and dc:GetCount()>0 then
				-- 中断效果处理，使得前后的处理在时点判定上不视为同时进行。
				Duel.BreakEffect()
				-- 为选中的即将弹回手牌的场上卡片播放被选择的动画效果。
				Duel.HintSelection(dc)
				-- 将选择的场上卡片送回持有者的手卡。
				Duel.SendtoHand(dc,nil,REASON_EFFECT)
			end
		end
	end
end
-- 过滤函数，筛选自己控制的「闪刀」怪兽。
function s.cfilter(c,tp)
	return c:IsSetCard(0x115) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
-- 效果②的发动条件，自己场上有「闪刀」怪兽被特殊召唤的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数，筛选额外卡组中可以通过连接召唤进行特殊召唤的「闪刀姬」连接怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsType(TYPE_LINK) and c:IsLinkSummonable(nil)
end
-- 效果②的发动目标，检查额外卡组中是否存在可召唤的连接怪兽，并注册特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测额外卡组中是否存在至少1只可以通过常规方式连接召唤出来的「闪刀姬」连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组中特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的具体处理逻辑，选择并进行1只「闪刀姬」连接怪兽的连接召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要从额外卡组进行特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选出1只符合连接召唤条件的「闪刀姬」连接怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择出来的连接怪兽在场上进行常规的连接召唤。
		Duel.LinkSummon(tp,g:GetFirst(),nil)
	end
end

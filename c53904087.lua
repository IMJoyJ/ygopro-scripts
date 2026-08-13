--神書の使いラハムゥ
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：只在连接召唤的这张卡表侧表示存在才有1次，自己在5星以上的怪兽召唤的场合需要的解放可以不用。
-- ②：自己·对方的主要阶段才能发动。进行1只5星以上的暗属性怪兽的召唤。
-- ③：自己结束阶段才能发动。手卡的怪兽任意数量给对方观看，用喜欢的顺序回到卡组下面。那之后，自己抽出回去的数量。
local s,id,o=GetID()
-- 定义怪兽的初始化函数：为“神书的使者 拉哈穆”注册连接召唤条件（效果怪兽2只）、苏生限制，以及①②③效果和一个用于识别自身效果的辅助标记效果。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只效果怪兽作为连接素材（符合“效果怪兽2只”的召唤条件）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：只在连接召唤的这张卡表侧表示存在才有1次，自己在5星以上的怪兽召唤的场合需要的解放可以不用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"使用「神书的使者 拉哈穆」效果不用解放召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(s.nttg)
	e1:SetOperation(s.ntop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。进行1只5星以上的暗属性怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段才能发动。手卡的怪兽任意数量给对方观看，用喜欢的顺序回到卡组下面。那之后，自己抽出回去的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"抽卡"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	-- ①效果中“只在连接召唤的这张卡表侧表示存在才有1次”的“这张卡”标记效果：为自身注册一个编码为卡号id的效果，用于在场上识别该卡拥有①效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(id)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- ①效果的召唤手续条件函数：当没有指定要召唤的怪兽时视为可适用；当指定怪兽时，要求该召唤无需解放、召唤区域有空位，且此卡为连接召唤出场。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 具体条件：这次召唤不需要解放（minc==0），自己主要怪兽区有空位，且效果持有者是以连接召唤方式出场。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的适用对象筛选：只有5星以上的怪兽才能使用这个无解放召唤手续。
function s.nttg(e,c)
	return c:IsLevelAbove(5)
end
-- 筛选场上符合条件的持有①效果的此卡：未被使用过①效果（Flag未标记）、拥有①效果标记（IsHasEffect(id)）、且为连接召唤出场。
function s.ntefilter(c)
	return c:GetFlagEffect(id)==0 and c:IsHasEffect(id) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的实际处理：当场上存在多张符合条件的此卡时，由玩家选择其中一张并标记其已适用过①效果；仅有一张时直接标记，确保本回合①效果只适用1次。
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上符合条件（未被使用过①效果且连接召唤的此卡）的卡集合。
	local tg=Duel.GetMatchingGroup(s.ntefilter,tp,LOCATION_MZONE,0,nil)
	if tg:GetCount()>1 then
		-- 提示玩家从符合条件的多张同名卡中选择一张来处理①效果。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)  --"请选择要处理效果的卡"
		local g=tg:Select(tp,1,1,nil)
		-- 显示被选中卡的动画，并将其记录为当前效果涉及的对象。
		Duel.HintSelection(g)
		g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已适用过①效果"
	elseif tg:GetCount()==1 then
		tg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已适用过①效果"
	end
end
-- ②效果要召唤的怪兽的过滤条件：5星以上、暗属性，且当前可以进行通常召唤。
function s.sumfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonable(true,nil)
end
-- ②效果的发动条件：仅限自己或对方的主要阶段。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否是主要阶段。
	return Duel.IsMainPhase()
end
-- ②效果发动时的目标检查与操作信息设置：确认玩家可以进行通常召唤且存在符合条件的怪兽，然后将本次效果标记为进行一次召唤。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己是否可以通常召唤，并且场上/手牌中存在5星以上暗属性且可召唤的怪兽。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：本次效果将进行1只怪兽的通常召唤（数量为1，对象未定）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果处理：选择1只符合条件的怪兽，无视通常召唤次数限制进行通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌和场上选择1只满足条件的5星以上暗属性怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 执行这次通常召唤：忽略每回合的通常召唤次数限制，按通常召唤规则召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- ③效果中可返回卡组的怪兽的过滤条件：是怪兽、可以返回卡组、且当前不是公开状态（未因其他效果公开）。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and not c:IsPublic()
end
-- ③效果的发动条件：必须在自己回合的结束阶段才能发动。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否是自己（即自己结束阶段）。
	return Duel.GetTurnPlayer()==tp
end
-- ③效果发动时的目标检查：自己可以抽卡，且手牌中存在符合条件的怪兽。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且手牌中存在至少1张满足条件的怪兽卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 将当前效果的对象玩家设为自己，用于后续抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：将手卡的卡返回卡组（预计至少1张，对象位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：选择任意数量手卡怪兽给对方确认，按玩家喜欢的顺序放回卡组底，然后抽取与返回数量相同的卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时要作用的玩家（即③效果的发动者）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择任意数量（1～63张）满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(p,s.filter,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()>0 then
		-- 将所选手卡给对方玩家确认，满足“给对方观看”的要求。
		Duel.ConfirmCards(1-p,g)
		-- 将所选卡按玩家喜欢的顺序放到卡组下面。
		aux.PlaceCardsOnDeckBottom(tp,g)
		-- 中断当前效果，使之后的抽卡处理视为不同时点，避免错过时点。
		Duel.BreakEffect()
		-- 自己抽取与返回卡组数量相同的卡（作为③效果后续的抽卡处理）。
		Duel.Draw(p,#g,REASON_EFFECT)
	end
end

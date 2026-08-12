--神書の使いラハムゥ
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：只在连接召唤的这张卡表侧表示存在才有1次，自己在5星以上的怪兽召唤的场合需要的解放可以不用。
-- ②：自己·对方的主要阶段才能发动。进行1只5星以上的暗属性怪兽的召唤。
-- ③：自己结束阶段才能发动。手卡的怪兽任意数量给对方观看，用喜欢的顺序回到卡组下面。那之后，自己抽出回去的数量。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤手续、启用特殊召唤限制，并注册三个效果
function s.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2张满足条件的卡作为连接素材
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
	-- 设置卡片的特殊效果，用于标记①效果是否已使用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(id)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 判断①效果是否满足发动条件，即是否为连接召唤且场上存在满足条件的怪兽
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足条件时，若无解放且场上存在空位，则允许发动①效果
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 设置①效果的目标过滤函数，筛选5星以上的怪兽
function s.nttg(e,c)
	return c:IsLevelAbove(5)
end
-- 设置①效果的过滤函数，筛选未使用过①效果且为连接召唤的怪兽
function s.ntefilter(c)
	return c:GetFlagEffect(id)==0 and c:IsHasEffect(id) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 执行①效果的操作，选择并标记使用过①效果的怪兽
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足①效果条件的怪兽组
	local tg=Duel.GetMatchingGroup(s.ntefilter,tp,LOCATION_MZONE,0,nil)
	if tg:GetCount()>1 then
		-- 提示玩家选择要处理效果的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)  --"请选择要处理效果的卡"
		local g=tg:Select(tp,1,1,nil)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已适用过①效果"
	elseif tg:GetCount()==1 then
		tg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已适用过①效果"
	end
end
-- 设置②效果的召唤目标过滤函数，筛选5星以上暗属性可通常召唤的怪兽
function s.sumfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonable(true,nil)
end
-- 设置②效果的发动条件，判断是否为主阶段
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为主阶段
	return Duel.IsMainPhase()
end
-- 设置②效果的目标处理函数，检查是否可以进行召唤
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以进行召唤，包括是否可以通常召唤及是否存在满足条件的怪兽
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置②效果的处理信息，指定将要进行召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 执行②效果的操作，选择并进行召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的怪兽进行召唤
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 执行通常召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 设置③效果的过滤函数，筛选可送回卡组的怪兽
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 设置③效果的发动条件，判断是否为自己的结束阶段
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 设置③效果的目标处理函数，检查是否可以发动效果
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡及是否存在满足条件的怪兽
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置③效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置③效果的处理信息，指定将要送回卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 执行③效果的操作，选择怪兽送回卡组并抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽送回卡组
	local g=Duel.SelectMatchingCard(p,s.filter,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()>0 then
		-- 确认对方查看送回卡组的怪兽
		Duel.ConfirmCards(1-p,g)
		-- 将怪兽按指定顺序放回卡组底端
		aux.PlaceCardsOnDeckBottom(tp,g)
		-- 中断当前效果，使后续处理视为错时点
		Duel.BreakEffect()
		-- 进行抽卡处理
		Duel.Draw(p,#g,REASON_EFFECT)
	end
end

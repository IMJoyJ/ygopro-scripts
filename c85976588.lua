--耀聖の月詩フォルトナ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
-- ②：自己主要阶段才能发动。从手卡·卡组把1张「耀圣」永续陷阱卡在自己场上表侧表示放置。
-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以让场上1张表侧表示的魔法·陷阱卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤规则，②主要阶段放置「耀圣」永续陷阱，③对方回合与中央怪兽交换位置并回手魔陷
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从手卡·卡组把1张「耀圣」永续陷阱卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置陷阱"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.ptg)
	e2:SetOperation(s.pop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以让场上1张表侧表示的魔法·陷阱卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"交换位置"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤规则的条件函数
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上中央的主要怪兽区域（区域掩码0x4）是否空闲
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,0x4)>0
end
-- 定义特殊召唤规则的数值函数，设定特殊召唤到中央的主要怪兽区域（区域掩码0x4）
function s.spval(e,c)
	return 0,0x4
end
-- 过滤条件：手卡·卡组中可表侧表示放置的「耀圣」永续陷阱卡
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsSetCard(0x1d8)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 定义放置效果的发动准备函数
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡或卡组中是否存在满足条件的「耀圣」永续陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 定义放置效果的处理函数
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域已无空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡或卡组选择1张满足条件的「耀圣」永续陷阱卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 若成功选出，则将该卡在自己的魔法与陷阱区域表侧表示放置
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 定义交换位置效果的发动条件函数
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否在主要怪兽区域，且当前回合玩家为对方
	return e:GetHandler():GetSequence()<5 and Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：位于中央主要怪兽区域（索引为2）的怪兽
function s.chfilter(c)
	return c:GetSequence()==2
end
-- 定义交换位置效果的发动准备函数
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查中央的主要怪兽区域是否存在除自身以外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 过滤条件：场上表侧表示的、可以回到手牌的魔法·陷阱卡
function s.rthfilter(c)
	return c:IsFaceup() and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义交换位置效果的处理函数
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cs=c:GetSequence()
	if not c:IsRelateToChain() or not c:IsControler(tp) or cs>4 or cs==2 then return end
	-- 获取中央主要怪兽区域的怪兽
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 交换自身与中央怪兽的位置
		Duel.SwapSequence(c,tc)
		if c:GetSequence()==cs then return end
		-- 检查场上是否存在表侧表示的魔法·陷阱卡
		if Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否发动让魔法·陷阱卡回到手牌的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让魔陷回到手卡？"
			-- 中断效果连接，使后续的回手牌处理与位置交换不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择场上1张表侧表示的魔法·陷阱卡
			local rg=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			-- 选中卡片并向双方玩家展示
			Duel.HintSelection(rg)
			-- 将选中的卡片送回持有者的手牌
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end

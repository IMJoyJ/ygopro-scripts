--ベアルクティ・クィントチャージ
-- 效果：
-- ①：1回合1次，可以支付700基本分，从以下效果选择1个发动。
-- ●从自己墓地选1只「北极天熊」怪兽加入手卡。
-- ●自己场上2只「北极天熊」怪兽解放，把持有和那个等级差相同等级的1只「北极天熊」怪兽从额外卡组无视召唤条件特殊召唤。
-- ②：自己的「北极天熊」同调怪兽被对方的攻击破坏时才能发动。对方直到自身的手卡·场上·墓地的卡合计变成7张为止必须回到持有者卡组。
function c15758127.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：1回合1次，可以支付700基本分，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c15758127.cost)
	e2:SetTarget(c15758127.target)
	e2:SetOperation(c15758127.activate)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：自己的「北极天熊」同调怪兽被对方的攻击破坏时才能发动。对方直到自身的手卡·场上·墓地的卡合计变成7张为止必须回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15758127,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c15758127.tdcon)
	e3:SetTarget(c15758127.tdtg)
	e3:SetOperation(c15758127.tdop)
	c:RegisterEffect(e3)
end
-- 支付700基本分的费用处理
function c15758127.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付700基本分
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	-- 让玩家支付700基本分
	Duel.PayLPCost(tp,700)
end
-- 过滤函数：检索满足条件的「北极天熊」怪兽（可加入手卡）
function c15758127.thfilter(c)
	return c:IsSetCard(0x163) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤函数：检索满足条件的「北极天熊」怪兽（可解放）
function c15758127.rfilter(c,tp)
	return (c:IsFaceup() or c:IsControler(tp)) and c:IsLevelAbove(1) and c:IsSetCard(0x163)
end
-- 过滤函数：判断组中是否存在满足等级差条件的怪兽
function c15758127.mnfilter(c,g,lv)
	return g:IsExists(c15758127.mnfilter2,1,c,c,lv)
end
-- 过滤函数：判断两个怪兽的等级差是否等于指定等级
function c15758127.mnfilter2(c,mc,lv)
	return c:GetLevel()-mc:GetLevel()==lv
end
-- 过滤函数：检索满足条件的「北极天熊」怪兽（可特殊召唤）
function c15758127.spfilter(c,e,tp,g)
	-- 判断怪兽是否为「北极天熊」、可特殊召唤且额外卡组有召唤空间
	return c:IsSetCard(0x163) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
-- 过滤函数：检索满足条件的「北极天熊」怪兽（可特殊召唤）
function c15758127.spfilter1(c,e,tp,g)
	return c15758127.spfilter(c,e,tp,g) and g:IsExists(c15758127.mnfilter,1,nil,g,c:GetLevel())
end
-- 过滤函数：检索满足等级条件的「北极天熊」怪兽（可特殊召唤）
function c15758127.spfilter2(c,e,tp,lv)
	return c15758127.spfilter(c,e,tp,nil) and c:IsLevel(lv)
end
-- 过滤函数：判断组中是否存在满足2只怪兽解放并满足等级差条件的组合
function c15758127.fselect(g,e,tp)
	-- 判断组中是否存在满足2只怪兽解放并满足等级差条件的组合
	return g:GetCount()==2 and Duel.IsExistingMatchingCard(c15758127.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 设置效果选择的处理逻辑
function c15758127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在「北极天熊」怪兽
	local b1=Duel.IsExistingMatchingCard(c15758127.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	-- 获取玩家可解放的「北极天熊」怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c15758127.rfilter,nil,tp)
	local b2=g:CheckSubGroup(c15758127.fselect,2,2,e,tp)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 选择“加入手卡”选项
		s=Duel.SelectOption(tp,aux.Stringid(15758127,0))  --"加入手卡"
	elseif not b1 and b2 then
		-- 选择“特殊召唤”选项
		s=Duel.SelectOption(tp,aux.Stringid(15758127,1))+1  --"特殊召唤"
	elseif b1 and b2 then
		-- 选择“加入手卡/特殊召唤”选项
		s=Duel.SelectOption(tp,aux.Stringid(15758127,0),aux.Stringid(15758127,1))  --"加入手卡/特殊召唤"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置操作信息为将墓地怪兽加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息为从额外卡组特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 效果发动的处理逻辑
function c15758127.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的墓地「北极天熊」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15758127.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:GetLabel()==1 then
		-- 获取玩家可解放的「北极天熊」怪兽组
		local g=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c15758127.rfilter,nil,tp)
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local rg=g:SelectSubGroup(tp,c15758127.fselect,false,2,2,e,tp)
		if rg and rg:GetCount()==2 then
			local c1=rg:GetFirst()
			local c2=rg:GetNext()
			local lv=c1:GetLevel()-c2:GetLevel()
			if lv<0 then lv=-lv end
			-- 判断是否成功解放2只怪兽
			if Duel.Release(rg,REASON_EFFECT)==2 then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 选择满足等级差条件的额外卡组怪兽
				local sg=Duel.SelectMatchingCard(tp,c15758127.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
				if sg:GetCount()>0 then
					-- 将选中的怪兽特殊召唤
					Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 过滤函数：判断怪兽是否为「北极天熊」同调怪兽
function c15758127.cfilter(c,tp)
	return c:IsPreviousSetCard(0x163) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0 and c:GetPreviousControler()==tp
end
-- 判断是否满足效果发动条件
function c15758127.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果发动条件
	return eg:IsExists(c15758127.cfilter,1,nil,tp) and Duel.GetAttacker():IsControler(1-tp)
end
-- 设置效果发动的处理逻辑
function c15758127.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手牌、场上、墓地的卡组
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if chk==0 then return #g>7 end
	-- 设置操作信息为将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,#g-7,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果发动的处理逻辑
function c15758127.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手牌、场上、墓地的卡数量
	local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 获取玩家手牌、场上、墓地可送回卡组的卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if ct<=7 or #g==0 then return end
	local tct=math.min(ct-7,#g)
	-- 提示对方选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(1-tp,tct,tct,nil)
	-- 将选中的卡送回卡组
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_RULE)
end

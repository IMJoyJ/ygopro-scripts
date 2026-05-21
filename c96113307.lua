--聖霊獣騎 レイラウタリ
-- 效果：
-- 效果怪兽3只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，双方不能为让卡的效果发动而把卡解放。
-- ②：以自己的除外状态的1张「灵兽」卡为对象才能发动。那张卡回到手卡·额外卡组。那之后，可以进行手卡1只「灵兽」怪兽的召唤。
-- ③：对方回合，以自己场上1张「灵兽」卡和对方场上1张卡为对象才能发动。那些卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、不能解放的永续效果、回收除外卡并召唤的起动效果，以及对方回合除外双方场上卡的诱发即时效果。
function s.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽3只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，双方不能为让卡的效果发动而把卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rellimit)
	c:RegisterEffect(e1)
	-- ②：以自己的除外状态的1张「灵兽」卡为对象才能发动。那张卡回到手卡·额外卡组。那之后，可以进行手卡1只「灵兽」怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.bstg)
	e2:SetOperation(s.bsop)
	c:RegisterEffect(e2)
	-- ③：对方回合，以自己场上1张「灵兽」卡和对方场上1张卡为对象才能发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 限制不能作为发动效果的Cost（代价）而解放。
function s.rellimit(e,c,tp,r)
	return r&REASON_COST~=0
end
-- 过滤条件：自己除外状态的表侧表示「灵兽」卡，且能加入手卡。
function s.bfilter(c)
	return c:IsSetCard(0xb5) and c:IsFaceup() and c:IsAbleToHand()
end
-- 过滤条件：手卡中可以进行通常召唤的「灵兽」怪兽。
function s.sfilter(c)
	return c:IsSetCard(0xb5) and c:IsSummonable(true,nil)
end
-- 效果②的发动准备与目标选择，判断目标卡是回到额外卡组还是手卡，并设置相应的操作信息。
function s.bstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.bfilter(chkc) end
	-- 检查自己除外状态是否存在至少1张满足条件的「灵兽」卡。
	if chk==0 then return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
	-- 选择自己除外状态的1张「灵兽」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.bfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsAbleToExtra() then
		-- 设置操作信息：将选中的卡回到额外卡组。
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	else
		-- 设置操作信息：将选中的卡回到手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果②的处理：将作为对象的卡回到手卡或额外卡组，之后可选择是否将手卡中的1只「灵兽」怪兽进行召唤。
function s.bsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的效果对象。
	local tc=Duel.GetTargetsRelateToChain():GetFirst()
	if tc then
		-- 尝试将对象卡送回手卡（或额外卡组），并判断是否成功。
		if Duel.SendtoHand(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			-- 检查手卡中是否存在可以召唤的「灵兽」怪兽。
			and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND,0,1,nil)
			-- 询问玩家是否进行「灵兽」怪兽的召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把怪兽召唤？"
			-- 中断当前效果处理，使后续的召唤处理不与回收卡片同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手卡选择1只满足条件的「灵兽」怪兽。
			local sumc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
			-- 如果成功选择，则对该怪兽进行通常召唤。
			if sumc then Duel.Summon(tp,sumc,true,nil) end
		end
	end
end
-- 效果③的发动条件：对方回合。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：自己场上表侧表示且可以被除外的「灵兽」卡。
function s.rmfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xb5) and c:IsAbleToRemove()
end
-- 效果③的发动准备与目标选择，分别选择自己场上的「灵兽」卡和对方场上的卡作为对象，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以除外的「灵兽」卡。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在可以除外的卡。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择自己场上要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1张「灵兽」卡作为效果对象。
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择对方场上要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张卡作为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：将选中的卡片除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 效果③的处理：将作为对象的双方场上的卡除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的效果对象集合。
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将这些卡以表侧表示除外。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end

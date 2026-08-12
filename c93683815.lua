--聖竜ヴルミナ像
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己的陷阱卡的效果让怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡回到手卡。那之后，可以把这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡在自己的灵摆区域放置，那只对方怪兽回到手卡。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆属性设置、怪兽效果①、怪兽效果②和灵摆效果①。
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡在自己的灵摆区域放置，那只对方怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方怪兽回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"在灵摆区域放置"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.pencon)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	-- ①：自己的陷阱卡的效果让怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡回到手卡。那之后，可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 怪兽效果①的触发条件：对方怪兽进行攻击宣言时。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- 怪兽效果①的靶向/发动合法性检测与操作信息设置。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	-- 检查攻击怪兽是否仍处于战斗中、是否能回到手卡，以及自己的灵摆区域是否有空位。
	if chk==0 then return at:IsRelateToBattle() and at:IsAbleToHand() and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	-- 将攻击怪兽设为当前效果的处理对象。
	Duel.SetTargetCard(at)
	-- 设置操作信息，表示该效果包含将该攻击怪兽送回手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,at,1,0,0)
end
-- 怪兽效果①的效果处理函数：将自身放置到灵摆区域，并将对方攻击怪兽回到手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否与效果相关联，并成功将自身移动到自己的灵摆区域。
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and c:IsLocation(LOCATION_PZONE) then
		-- 获取作为效果处理对象的攻击怪兽。
		local at=Duel.GetFirstTarget()
		if at:IsControler(1-tp) and at:IsType(TYPE_MONSTER) then
			-- 将该攻击怪兽送回持有者的手卡。
			Duel.SendtoHand(at,nil,REASON_EFFECT)
		end
	end
end
-- 怪兽效果②的触发条件：自身原本在怪兽区域且被破坏并表侧表示存在。
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②的靶向/发动合法性检测：检查灵摆区域是否有空位，若在墓地则设置离开墓地的操作信息。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 若自身在墓地被破坏，设置操作信息为该卡离开墓地。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 怪兽效果②的效果处理：将自身在自己的灵摆区域放置。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身移动并表侧表示放置到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 过滤条件：检查怪兽是否是由自己发动的陷阱卡的效果特殊召唤的。
function s.cfilter(c,tp)
	local typ,se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and typ&TYPE_TRAP~=0 and se:IsActivated() and sp==tp
end
-- 灵摆效果①的触发条件：自己的陷阱卡的效果让怪兽特殊召唤的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 灵摆效果①的靶向/发动合法性检测：选择场上1张卡作为对象，并设置回手卡和特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsAbleToHand() end
	-- 检查场上是否存在可以回到手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择场上1张可以回到手卡的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示该效果包含将选中的卡送回手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息，表示该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果①的效果处理：使对象卡回到手卡，之后可以把这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果处理对象的场上的卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查对象卡是否仍与效果相关联，并成功将其送回手卡。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 检查自己的怪兽区域是否有空位，以及自身是否可以特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查自身是否仍在灵摆区域，并询问玩家是否选择将这张卡特殊召唤。
			and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与回手卡不视为同时进行。
			Duel.BreakEffect()
			-- 将自身以表侧表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

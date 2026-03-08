--A・O・J リーサル・ウェポン
-- 效果：
-- 这张卡战斗破坏光属性怪兽送去墓地时，从自己卡组抽1张卡。这个效果抽到的卡是4星以下的暗属性怪兽的场合，可以把那张卡给对方观看在自己场上特殊召唤。
function c45450218.initial_effect(c)
	-- 效果原文：这张卡战斗破坏光属性怪兽送去墓地时，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c45450218.checkop)
	c:RegisterEffect(e1)
	-- 效果原文：这个效果抽到的卡是4星以下的暗属性怪兽的场合，可以把那张卡给对方观看在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45450218,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c45450218.condition)
	e2:SetTarget(c45450218.target)
	e2:SetOperation(c45450218.operation)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 规则层面：判断攻击怪兽是否为光属性，是则设置标签为1，否则为0。
function c45450218.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取此次战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 规则层面：若攻击怪兽是自己，则获取攻击目标怪兽。
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc and tc:IsAttribute(ATTRIBUTE_LIGHT) then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 规则层面：判断被战斗破坏送入墓地的怪兽是否为光属性，且其破坏原因来自本卡，且标签为1。
function c45450218.condition(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:GetFirst()
	return eg:GetCount()==1 and dg:IsLocation(LOCATION_GRAVE) and dg:IsReason(REASON_BATTLE)
		and dg:IsAttribute(ATTRIBUTE_LIGHT) and dg:GetReasonCard()==e:GetHandler() and e:GetLabelObject():GetLabel()==1
end
-- 规则层面：设置连锁操作信息，表示将要进行抽卡操作。
function c45450218.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置操作信息为抽卡类别，抽1张卡给玩家tp。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面：执行效果，先抽卡，再判断是否满足特殊召唤条件。
function c45450218.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：让玩家tp从卡组抽1张卡。
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	-- 规则层面：若未抽到卡或场上无召唤空间，则不继续处理。
	if ct==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：获取实际抽到的卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 规则层面：询问玩家是否要特殊召唤该卡。
		and Duel.SelectYesNo(tp,aux.Stringid(45450218,1)) then  --"是否要特殊召唤？"
		-- 规则层面：向对方确认该卡的卡面信息。
		Duel.ConfirmCards(1-tp,tc)
		-- 规则层面：将该卡特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

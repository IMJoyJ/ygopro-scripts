--寡黙なるサイコプリースト
-- 效果：
-- 这张卡召唤·反转召唤成功时，变成守备表示。1回合1次，可以把1张手卡送去墓地，选择自己墓地存在的1只念动力族怪兽从游戏中除外。这张卡从场上送去墓地时，选择这张卡的效果除外的1只怪兽特殊召唤。
function c25343017.initial_effect(c)
	-- 这张卡召唤成功时，变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25343017,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c25343017.potg)
	e1:SetOperation(c25343017.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把1张手卡送去墓地，选择自己墓地存在的1只念动力族怪兽从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25343017,1))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c25343017.rmcost)
	e3:SetTarget(c25343017.rmtg)
	e3:SetOperation(c25343017.rmop)
	c:RegisterEffect(e3)
	-- 这张卡从场上送去墓地时，选择这张卡的效果除外的1只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25343017,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c25343017.spcon)
	e4:SetTarget(c25343017.sptg)
	e4:SetOperation(c25343017.spop)
	c:RegisterEffect(e4)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e4:SetLabelObject(ng)
	e3:SetLabelObject(e4)
end
-- 检查是否处于攻击表示，用于判断是否可以发动效果。
function c25343017.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置操作信息，表示将要改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 如果卡处于攻击表示且有效，则将其变为守备表示。
function c25343017.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将卡变为守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 支付1张手卡送去墓地的代价。
function c25343017.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为效果的代价。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤函数，用于筛选墓地中的念动力族怪兽。
function c25343017.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 设置选择目标，用于选择要除外的墓地中的念动力族怪兽。
function c25343017.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25343017.filter(chkc) end
	-- 检查是否存在满足条件的墓地中的念动力族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c25343017.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标卡，即墓地中的念动力族怪兽。
	local g=Duel.SelectTarget(tp,c25343017.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将要除外目标卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 执行除外操作，并记录被除外的卡。
function c25343017.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 判断目标卡是否有效且为念动力族，并执行除外操作。
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(25343017,RESET_EVENT+RESETS_STANDARD,0,0)
		e:GetLabelObject():SetLabel(1)
		if c:GetFlagEffect(25343017)==0 then
			c:RegisterFlagEffect(25343017,RESET_EVENT+0x1680000,0,0)
			e:GetLabelObject():GetLabelObject():Clear()
		end
		e:GetLabelObject():GetLabelObject():AddCard(tc)
	end
end
-- 判断是否满足特殊召唤的条件。
function c25343017.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rg=e:GetLabelObject()
	local act=e:GetLabel()
	e:SetLabel(0)
	if act==1 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetFlagEffect(25343017) then return true
	else rg:Clear() return false end
end
-- 过滤函数，用于筛选被除外的念动力族怪兽。
function c25343017.spfilter(c,e,tp)
	return c:GetFlagEffect(25343017)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的目标，用于选择要特殊召唤的怪兽。
function c25343017.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rg=e:GetLabelObject()
	if chkc then return rg:IsContains(chkc) and c25343017.spfilter(chkc,e,tp) end
	if chk==0 then
		if rg:IsExists(c25343017.spfilter,1,nil,e,tp) then return true
		else rg:Clear() return false end
	end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=rg:FilterSelect(tp,c25343017.spfilter,1,1,nil,e,tp)
	-- 设置当前处理的连锁的目标卡。
	Duel.SetTargetCard(sg)
	rg:Clear()
	-- 设置操作信息，表示将要特殊召唤目标卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 执行特殊召唤操作。
function c25343017.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

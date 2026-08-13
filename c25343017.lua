--寡黙なるサイコプリースト
-- 效果：
-- 这张卡召唤·反转召唤成功时，变成守备表示。1回合1次，可以把1张手卡送去墓地，选择自己墓地存在的1只念动力族怪兽从游戏中除外。这张卡从场上送去墓地时，选择这张卡的效果除外的1只怪兽特殊召唤。
function c25343017.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，变成守备表示。
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
-- 效果1的发动判定：确认这张卡为攻击表示，并登记将其变成守备表示的操作信息。
function c25343017.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 登记本次效果操作的信息：将这张卡变成守备表示（CATEGORY_POSITION），供后续时点检测等系统判断。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果1的实际处理：当这张卡仍为表侧攻击表示且与效果关联时，将其变更为表侧守备表示。
function c25343017.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 代价处理：先检查手牌是否有可作为代价送去墓地的卡，若有则丢弃1张手卡作为发动代价。
function c25343017.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中至少存在1张可以送去墓地的卡，否则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 实际丢弃1张手卡（送去墓地）作为发动代价。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 选择条件：自己墓地中1只念动力族怪兽，并且能够除外。
function c25343017.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 目标选择：确认墓地存在符合条件的念动力族怪兽；若存在，提示玩家选择1只作为对象，并登记除外操作信息。
function c25343017.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25343017.filter(chkc) end
	-- 发动条件检查：确认自己墓地存在1只符合条件的念动力族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c25343017.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只符合条件的念动力族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c25343017.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次效果将把目标怪兽除外的操作信息（CATEGORY_REMOVE），来源区域为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理：将选中的念动力族怪兽除外；若成功且本卡仍关联，则给该怪兽打上“被此效果除外”的标记，并把该怪兽加入本卡后续特殊召唤效果的记录组中，同时给本卡标记已发动过此除外效果。
function c25343017.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡（被选择的墓地念动力族怪兽）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 处理条件：对象卡仍与效果关联且仍为念动力族，并成功除外（返回值非0），且这张卡仍与效果关联时，才继续记录。
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
-- 特殊召唤效果的发动条件：此前除外效果已成功发动过（标记为1），并且本卡是从场上送去墓地，且本卡带有对应标记时，才允许发动；否则清空记录组并返回false。
function c25343017.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rg=e:GetLabelObject()
	local act=e:GetLabel()
	e:SetLabel(0)
	if act==1 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetFlagEffect(25343017) then return true
	else rg:Clear() return false end
end
-- 特殊召唤对象条件：被除外的怪兽带有本效果记录标记，并且可以被当前效果特殊召唤。
function c25343017.spfilter(c,e,tp)
	return c:GetFlagEffect(25343017)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标选择：确认记录组中是否存在可特殊召唤的怪兽；若有，让玩家选择1只，设为效果对象，并清空记录组（本次只特殊召唤其中1只），同时登记特殊召唤操作信息。
function c25343017.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rg=e:GetLabelObject()
	if chkc then return rg:IsContains(chkc) and c25343017.spfilter(chkc,e,tp) end
	if chk==0 then
		if rg:IsExists(c25343017.spfilter,1,nil,e,tp) then return true
		else rg:Clear() return false end
	end
	-- 显示选择提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=rg:FilterSelect(tp,c25343017.spfilter,1,1,nil,e,tp)
	-- 将选中的怪兽设置为当前连锁的效果对象（取对象），确保后续处理时正确关联。
	Duel.SetTargetCard(sg)
	rg:Clear()
	-- 登记本次效果将特殊召唤所选怪兽的操作信息（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 特殊召唤效果的实际处理：若对象怪兽仍与效果关联，则将其表侧攻击表示特殊召唤。
function c25343017.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡（被选为特殊召唤对象的除外怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到发动者场上（不检查召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

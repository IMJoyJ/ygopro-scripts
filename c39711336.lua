--不死王リッチー
-- 效果：
-- 这张卡不能通常召唤。满足条件的「大神官 迪·扎德」做祭品特殊召唤。这张卡1个回合可以有1次变成里侧守备表示。场上表侧表示存在的这张卡为对象的魔法·陷阱卡的发动和效果无效并破坏。这张卡反转时，选择自己的墓地的1只不死族怪兽特殊召唤上场。
function c39711336.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡1个回合可以有1次变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39711336,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c39711336.target)
	e1:SetOperation(c39711336.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，选择自己的墓地的1只不死族怪兽特殊召唤上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39711336,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c39711336.sptg)
	e2:SetOperation(c39711336.spop)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡为对象的魔法·陷阱卡的发动和效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCondition(c39711336.discon)
	e3:SetTarget(c39711336.distg)
	e3:SetOperation(c39711336.disop)
	c:RegisterEffect(e3)
end
-- 起动效果发动条件：此卡表侧表示且在主要怪兽区、本回合未使用过该效果，且可以被变为里侧守备表示；满足时给自身设置本回合使用过的标记，并写入改变表示形式的操作信息。
function c39711336.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(39711336)==0 end
	c:RegisterFlagEffect(39711336,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置本次效果处理为改变表示形式，对象为此卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若此卡仍与效果关联且表侧表示，则将其变更为里侧守备表示。
function c39711336.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：是不死族怪兽且能够被玩家tp以效果特殊召唤。
function c39711336.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 反转效果的目标选择：若自己场上有空位且墓地存在满足条件的不死族怪兽，则可选择其中1只为对象。
function c39711336.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39711336.spfilter(chkc,e,tp) end
	-- 判断自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地是否存在满足条件的不死族怪兽可供选择。
		and Duel.IsExistingTarget(c39711336.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的不死族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c39711336.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果处理为特殊召唤，对象为已选择的卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，获取对象卡，若仍与效果关联且是不死族怪兽，则将其特殊召唤。
function c39711336.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将对象卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 无效效果发动条件：对方发动的魔法·陷阱卡是以表侧的此卡为对象的取对象效果，且是魔法·陷阱卡的发动，则满足条件。
function c39711336.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取发动中的连锁的效果对象卡片组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 无效效果的发动判定：无条件可发动；设置操作信息为无效那次魔法·陷阱卡的发动，若该卡可以被破坏则追加破坏。
function c39711336.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为否定（无效）该魔法·陷阱卡的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏该魔法·陷阱卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时，若当前连锁正是需要无效的连锁，则无效其发动；若无效成功且对象卡仍存在，则将该卡破坏。
function c39711336.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前正在处理的连锁是否为被无效的连锁（ev+1），否则不处理。
	if Duel.GetCurrentChain()~=ev+1 then return end
	-- 若成功无效该魔法·陷阱卡的发动，且其卡仍与效果关联，则继续破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将那张魔法·陷阱卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

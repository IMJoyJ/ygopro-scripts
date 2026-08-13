--忍法装具 鉄土竜
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。
-- ②：从自己墓地把1只「忍者」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册忍法装具 铁土龙的所有效果：装备对象限制、装备魔法发动、①攻击力提升与视为「忍者」、②除外「忍者」怪兽破坏场上1张卡、③从场上送去墓地时回收或里侧守备表示特殊召唤除外的「忍者」怪兽。
function s.initial_effect(c)
	-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。（装备对象限制）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。（装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetValue(0x2b)
	c:RegisterEffect(e3)
	-- ②：从自己墓地把1只「忍者」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(s.rtcon)
	e5:SetTarget(s.rttg)
	e5:SetOperation(s.rtop)
	c:RegisterEffect(e5)
end
-- 装备魔法发动时的目标选择：从双方场上选择1只表侧表示怪兽作为装备对象，并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动的合法性检查：确认双方怪兽区存在至少1只表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动玩家显示“请选择要装备的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只表侧表示怪兽作为装备对象，并将其登记为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为装备这张卡（CATEGORY_EQUIP），目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动后的处理：确认本卡和对象仍与效果关联且对象为表侧表示时，将这张卡装备给对象怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查本卡和对象怪兽是否仍与当前效果关联且对象表侧表示，满足条件则将本卡装备给对象怪兽。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
-- ②效果的除外费用筛选条件：从自己墓地选择1只「忍者」怪兽且可以作为除外费用。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从自己墓地除外1只「忍者」怪兽。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用支付合法性检查：确认自己墓地存在至少1只满足条件的「忍者」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给发动玩家显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只「忍者」怪兽作为除外费用。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「忍者」怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标选择：选择场上1张卡作为要破坏的对象，并设置操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 目标选择合法性检查：确认场上存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为破坏对象，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息为破坏（CATEGORY_DESTROY），指定对象和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：破坏之前选择的对象卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联后，将其破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- ③效果的目标过滤函数：限定除外区的自己的表侧表示「忍者」怪兽，且能够加入手卡或能够里侧守备表示特殊召唤。
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b)
		and (c:IsAbleToHand()
			-- 其中特殊召唤分支需要自己主要怪兽区有空位，且该怪兽可以被里侧守备表示特殊召唤。
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
end
-- ③效果的发动条件：这张卡从场上被送去墓地（即发动前位于场上）。
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果的目标选择：从除外的自己的「忍者」怪兽中选择1只满足条件的怪兽，并登记为效果对象。
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 目标选择合法性检查：确认除外区存在至少1只满足条件的自己的「忍者」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给发动玩家显示“请选择要操作的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从除外的自己的「忍者」怪兽中选择1只作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
end
-- ③效果处理：对对象怪兽选择“加入手卡”或“里侧守备表示特殊召唤”；选择特殊召唤时若成功则向对方确认该怪兽，否则加入手卡。
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断自己主要怪兽区是否有空位且对象怪兽可以被里侧守备表示特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 如果对象怪兽不能加入手卡，则直接选择特殊召唤；若可以加入手卡，则弹出选项让玩家选择“加入手卡”或“里侧守备表示特殊召唤”。
		and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
		-- 将对象怪兽以里侧守备表示特殊召唤到自己场上，并检查是否成功。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			-- 向对方玩家确认特殊召唤成功的那只里侧守备表示的怪兽。
			Duel.ConfirmCards(1-tp,tc)
		end
	else
		-- 将对象怪兽送去持有者的手卡（对应“加入手卡”选项）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

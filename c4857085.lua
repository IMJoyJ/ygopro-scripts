--Ωメガネ
-- 效果：
-- 这张卡只有自己场上的怪兽才能装备。1回合1次，对方手卡随机选择1张确认。这个效果发动的回合，装备怪兽不能攻击。
function c4857085.initial_effect(c)
	-- 这张卡只有自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c4857085.target)
	e1:SetOperation(c4857085.operation)
	c:RegisterEffect(e1)
	-- 这张卡只有自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c4857085.eqlimit)
	c:RegisterEffect(e2)
	-- 1回合1次，对方手卡随机选择1张确认。这个效果发动的回合，装备怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4857085,0))  --"确认手牌"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c4857085.cfcost)
	e3:SetTarget(c4857085.cftg)
	e3:SetOperation(c4857085.cfop)
	c:RegisterEffect(e3)
end
-- 装备限制判定：只有这张卡的操作者（装备玩家）场上的怪兽才能作为装备对象。
function c4857085.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 发动时的取对象处理：选择自己场上1只表侧表示怪兽作为装备对象，并设置装备类操作信息。
function c4857085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动合法性检查：自己场上是否存在至少1只表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让自己从自己场上的表侧表示怪兽中选择1只作为这张卡的装备对象，并登记为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本次连锁的操作信息为装备效果，处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽仍与效果关联且怪兽表侧表示，则将这张卡装备给该怪兽。
function c4857085.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 发动“确认手牌”效果的代价：装备怪兽本回合未进行过攻击宣言，且给装备怪兽附加不能攻击的誓约效果。
function c4857085.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipTarget():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，装备怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 确认手牌效果的发动合法性：对方手牌存在至少1张卡。
function c4857085.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 效果处理：从对方手牌中随机选择1张，给发动玩家确认，然后洗切对方手牌。
function c4857085.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选出的那张对方手牌展示给发动玩家确认。
	Duel.ConfirmCards(tp,sg)
	-- 洗切对方的手牌，使被确认的卡随机回到手牌中。
	Duel.ShuffleHand(1-tp)
end

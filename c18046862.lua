--嘆きの石版
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：装备怪兽不能攻击，效果无效化，不能解放。
-- ②：1回合1次，装备怪兽在自己场上存在的场合才能发动。从卡组把「叹息之石版」以外的1张「石版」卡加入手卡。
-- ③：装备怪兽被破坏让这张卡被送去墓地的场合才能发动。给与对方500伤害。
local s,id,o=GetID()
-- 注册本卡全部效果：e0为装备魔法发动效果（取对象装备，含同名卡1回合1次发动限制）；e1使装备怪兽不能攻击；e2使装备怪兽效果无效化；e3/e4使装备怪兽不能作为上级召唤及其他解放的祭品；e5为②检索效果；e6为③伤害效果；e7为装备对象限制（仅可装备给怪兽）。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	-- 装备怪兽不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	-- 效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- 不能解放
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	-- ②：1回合1次，装备怪兽在自己场上存在的场合才能发动。从卡组把「叹息之石版」以外的1张「石版」卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	-- ③：装备怪兽被破坏让这张卡被送去墓地的场合才能发动。给与对方500伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))  --"给与伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(s.damcon)
	e6:SetTarget(s.damtg)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
	-- 装备怪兽（装备对象限制，只能装备给怪兽）
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_EQUIP_LIMIT)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end
-- 装备魔法发动时的目标处理：检查场上是否至少存在1只表侧表示怪兽，若有则让发动者选择1只作为装备对象，并登记装备操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动时点检查：场上是否存在至少1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示发动者选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让发动者从双方场上的表侧表示怪兽中选择1只，并登记为这张装备魔法的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将进行装备魔法卡的装备处理，对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备魔法的发动处理：若此卡和装备对象仍然关联且对象仍为表侧表示，则将此卡装备给对象怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给对象怪兽，完成装备处理。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ②检索效果的发动条件：此卡装备中的怪兽存在，且装备怪兽的控制者与此卡控制者相同，即装备怪兽在自己场上。
function s.thcon(e)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	return tc and c:GetControler()==tc:GetControler()
end
-- 检索筛选条件：不是「叹息之石版」，卡名属于「石版」字段，并且能够加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1b6) and c:IsAbleToHand()
end
-- ②检索效果的目标处理：检查卡组中是否存在符合条件的「石版」卡，并设置从卡组将1张「石版」卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：卡组中是否存在至少1张符合条件的「石版」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组将1张「石版」卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②检索效果处理：发动者从卡组选择1张符合条件的「石版」卡加入手卡，并让对方确认加入的卡片。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动者选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 发动者从卡组中选择1张符合条件的「石版」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡（以效果处理的方式）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③伤害效果的发动条件：此卡因装备怪兽被破坏而失去装备对象并被送去墓地，且装备怪兽是被破坏的。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY)
end
-- ③伤害效果的目标处理：将对象玩家设为对方，设定伤害数值为500，并登记造成500点伤害的操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家，作为伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为500，作为伤害数值。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本连锁将对对方造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ③伤害效果的处理：读取连锁中设定的对象玩家和伤害值，对对方造成500点效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中读取对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对对象玩家造成500点伤害，伤害原因为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end

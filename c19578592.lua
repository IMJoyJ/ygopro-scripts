--愚鈍の斧
-- 效果：
-- ①：装备怪兽的攻击力上升1000，效果无效化。
-- ②：自己准备阶段发动。给与装备怪兽的控制者500伤害。
function c19578592.initial_effect(c)
	-- ①：装备怪兽的攻击力上升1000，效果无效化。（作为装备魔法发动，选择场上表侧表示怪兽装备此卡）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19578592.target)
	e1:SetOperation(c19578592.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升1000，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	-- ①：装备怪兽的攻击力上升1000，效果无效化。（装备对象限定为怪兽）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ②：自己准备阶段发动。给与装备怪兽的控制者500伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19578592,0))  --"500伤害"
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c19578592.damcon)
	e5:SetTarget(c19578592.damtg)
	e5:SetOperation(c19578592.damop)
	c:RegisterEffect(e5)
end
-- 发动时的目标处理：检查场上是否存在表侧表示怪兽，若存在则让玩家选择1只表侧表示怪兽作为装备对象，并设置此卡进行装备的处理信息。
function c19578592.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查我方或对方场上是否存在至少1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，让当前玩家选择要装备此卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示怪兽作为此卡的装备对象，并将其记录为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本连锁将把此卡作为装备卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：若此卡和对象卡仍与本效果关联且对象仍表侧表示，则将此卡装备给对象怪兽；否则装备失败。
function c19578592.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将“愚钝之斧”作为装备卡装备给对象怪兽（装备后由装备效果提供加成与无效化）。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ②效果的发动条件判断：仅在效果控制者自己的准备阶段满足条件。
function c19578592.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否就是效果的控制者（即自己的准备阶段）。
	return tp==Duel.GetTurnPlayer()
end
-- ②效果发动时的目标处理：确定装备怪兽的控制者为受到伤害的玩家，伤害数值为500，并设置对应的伤害操作信息。
function c19578592.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 将当前连锁的对象玩家设置为装备怪兽的控制者，即伤害的承受者。
	Duel.SetTargetPlayer(p)
	-- 将当前连锁的对象参数设置为500，表示准备给予的伤害数值。
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息：将对对象玩家造成500点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
-- ②效果处理时：对装备怪兽的控制者造成记录数值的效果伤害。
function c19578592.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 取得当前连锁中记录的伤害数值（即500）。
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 对装备怪兽的控制者p造成d点效果伤害（以该效果为伤害来源）。
	Duel.Damage(p,d,REASON_EFFECT)
end

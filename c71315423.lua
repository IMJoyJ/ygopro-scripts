--ワーム・ミリディス
-- 效果：
-- 反转：这张卡可以当作装备卡使用给1只对方怪兽装备。每次准备阶段，给与装备怪兽的控制者400分伤害。
function c71315423.initial_effect(c)
	-- 反转：这张卡可以当作装备卡使用给1只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c71315423.eqtg)
	e1:SetOperation(c71315423.eqop)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象合法性检查与发动条件判断（自身在场上表侧表示、魔陷区有空位、未被战斗破坏）
function c71315423.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup()
		-- 检查自身魔法与陷阱区域是否有可用的空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) end
	-- 给发动效果的玩家发送“请选择要装备的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表示该效果包含将自身装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身作为装备卡装备给目标怪兽，并注册装备限制与准备阶段造成伤害的效果
function c71315423.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因效果处理时目标怪兽不合法，将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 每次准备阶段，给与装备怪兽的控制者400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71315423,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c71315423.damtg)
	e1:SetOperation(c71315423.damop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 这张卡可以当作装备卡使用给1只对方怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c71315423.eqlimit)
	e2:SetLabelObject(tc)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制：此卡只能装备给作为效果对象的怪兽
function c71315423.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 伤害效果的发动准备，确认效果处理时将对装备怪兽的控制者造成伤害
function c71315423.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表示该效果在处理时会给与装备怪兽的控制者400点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetHandler():GetEquipTarget():GetControler(),400)
end
-- 伤害效果的处理：获取装备怪兽，并给与其控制者400点伤害
function c71315423.damop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	if tg then
		-- 给与装备怪兽的控制者400点伤害
		Duel.Damage(tg:GetControler(),400,REASON_EFFECT)
	end
end

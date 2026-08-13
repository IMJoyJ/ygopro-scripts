--ワンショット・ワンド
-- 效果：
-- 魔法师族怪兽才能装备。装备怪兽的攻击力上升800。此外，装备怪兽进行战斗的伤害计算后，可以把这张卡破坏并从卡组抽1张卡。
function c36042825.initial_effect(c)
	-- 魔法师族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c36042825.target)
	e1:SetOperation(c36042825.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 魔法师族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c36042825.eqlimit)
	c:RegisterEffect(e3)
	-- 此外，装备怪兽进行战斗的伤害计算后，可以把这张卡破坏并从卡组抽1张卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36042825,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c36042825.drcon)
	e4:SetTarget(c36042825.drtg)
	e4:SetOperation(c36042825.drop)
	c:RegisterEffect(e4)
end
-- 判定装备限制：仅允许装备魔法师族怪兽。
function c36042825.eqlimit(e,c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 过滤条件：场上表侧表示且为魔法师族的怪兽。
function c36042825.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动时的处理：选择场上1只表侧表示魔法师族怪兽作为装备对象，并设置装备效果的操作信息。
function c36042825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36042825.filter(chkc) end
	-- 发动合法性检查：确认场上存在满足条件的魔法师族表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c36042825.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示装备选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示魔法师族怪兽作为此卡的装备对象。
	Duel.SelectTarget(tp,c36042825.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 记录本连锁将进行装备操作，对象为本卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动后的处理：若本卡与对象卡仍与效果关联且对象卡表侧表示，则将本卡装备给对象怪兽。
function c36042825.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将本卡作为装备卡装备给选择的怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 诱发条件：装备怪兽进行过伤害计算且与本次战斗关联。
function c36042825.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget():IsRelateToBattle()
end
-- 发动时判定：可以抽1张卡；同时预定破坏本卡和进行1张抽卡的操作。
function c36042825.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认当前玩家能否因效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设定效果处理时将破坏本卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设定效果处理时玩家将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：破坏本卡成功后再抽1张卡。
function c36042825.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查本卡仍与效果关联，并尝试以效果破坏本卡，只有破坏成功才继续处理。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--ZW－天風精霊翼
-- 效果：
-- ①：「异热同心武器-天风精灵翼」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升800的装备卡使用给那只怪兽装备。
-- ③：1回合1次，对方发动的效果让怪兽特殊召唤的场合才能发动。装备怪兽的攻击力上升1600。
-- ④：装备怪兽把超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把这张卡送去墓地。
function c95886782.initial_effect(c)
	c:SetUniqueOnField(1,0,95886782)
	-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升800的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95886782,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(c95886782.eqcon)
	e1:SetTarget(c95886782.eqtg)
	e1:SetOperation(c95886782.eqop)
	c:RegisterEffect(e1)
	-- ③：1回合1次，对方发动的效果让怪兽特殊召唤的场合才能发动。装备怪兽的攻击力上升1600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95886782,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c95886782.atkcon)
	e2:SetOperation(c95886782.atkop)
	c:RegisterEffect(e2)
	-- ④：装备怪兽把超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95886782,2))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c95886782.repcon)
	e3:SetOperation(c95886782.repop)
	c:RegisterEffect(e3)
end
-- 检查自身在场上的唯一性（对应效果①）
function c95886782.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤自己场上表侧表示的「希望皇 霍普」怪兽
function c95886782.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备效果的对象选择与合法性检测
function c95886782.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c95886782.eqfilter(chkc) end
	-- 检查自己场上的魔陷区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为装备对象的「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c95886782.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定1只「希望皇 霍普」怪兽作为效果对象
	Duel.SelectTarget(tp,c95886782.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的执行：将自身作为装备卡装备给目标怪兽，若不满足条件则送去墓地
function c95886782.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷格、目标控制权、表示形式、对象关联性以及场上唯一性，判断是否无法正常装备
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 无法正常装备时，将这张卡因效果送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c95886782.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作，并为装备卡注册装备限制和攻击力上升800的永续效果
function c95886782.zw_equip_monster(c,tp,tc)
	-- 尝试将自身装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- ②：从自己的手卡·场上把这张卡当作……装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c95886782.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- ②：当作攻击力上升800的装备卡使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 限制这张卡只能装备给作为对象的那只怪兽
function c95886782.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤由对方发动的效果而特殊召唤成功的怪兽
function c95886782.cfilter(c,e,tp)
	local se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and sp==1-tp and se:IsActivated() and e:GetOwnerPlayer()==1-se:GetOwnerPlayer()
end
-- 检查自身是否处于装备状态，且对方发动的效果让怪兽特殊召唤成功
function c95886782.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
		and eg:IsExists(c95886782.cfilter,1,nil,e,tp)
end
-- 诱发效果处理：使装备怪兽的攻击力上升1600
function c95886782.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- ③：装备怪兽的攻击力上升1600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)
end
-- 代替去素材的条件判定：装备怪兽作为超量怪兽发动效果需要去除超量素材，且自身可以作为代替送去墓地
function c95886782.repcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and re:GetHandler():GetOverlayCount()>=ev-1
		and e:GetHandler():GetEquipTarget()==re:GetHandler() and e:GetHandler():IsAbleToGraveAsCost() and ep==e:GetOwnerPlayer()
end
-- 代替去素材的效果执行：将这张卡送去墓地作为代替
function c95886782.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为装备卡的自身送去墓地以代替去除超量素材
	return Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

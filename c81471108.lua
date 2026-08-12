--ZW－風神雲龍剣
-- 效果：
-- ①：「异热同心武器-风神云龙剑」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1300的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ③：这张卡装备中的场合，对方不能把装备怪兽作为效果的对象。
-- ④：装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
function c81471108.initial_effect(c)
	c:SetUniqueOnField(1,0,81471108)
	-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1300的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81471108,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(c81471108.eqcon)
	e1:SetTarget(c81471108.eqtg)
	e1:SetOperation(c81471108.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡装备中的场合，对方不能把装备怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方卡片效果的对象（过滤函数，仅限对方的效果）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ④：装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(c81471108.repval)
	c:RegisterEffect(e3)
end
-- 检查自己场上是否已存在同名卡（满足“只能有1张表侧表示存在”的条件）
function c81471108.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤自己场上表侧表示的「希望皇 霍普」怪兽
function c81471108.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备效果的靶向/目标选择函数，检查魔陷区空位及是否存在合法的「希望皇 霍普」怪兽，并进行取对象
function c81471108.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81471108.filter(chkc) end
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为装备对象的「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c81471108.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「希望皇 霍普」怪兽作为效果的对象
	Duel.SelectTarget(tp,c81471108.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的执行函数，处理将自身作为装备卡装备给目标怪兽的过程
function c81471108.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取效果发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、目标怪兽是否仍在自己场上表侧表示存在、目标怪兽是否仍适用此效果，以及自身是否满足场上唯一性限制
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c81471108.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作，并为装备卡（自身）注册装备限制和攻击力上升的效果
function c81471108.zw_equip_monster(c,tp,tc)
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 从自己的手卡·场上把这张卡当作……装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c81471108.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升1300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1300)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 限制这张卡只能装备给作为效果对象的怪兽
function c81471108.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤代替破坏的原因，仅在装备怪兽被战斗破坏时适用代替破坏
function c81471108.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end

--アーマード・エクシーズ
-- 效果：
-- ①：以自己场上1只表侧表示怪兽和自己墓地1只超量怪兽为对象才能发动。作为对象的墓地的怪兽当作持有以下效果的装备魔法卡使用给作为对象的场上的怪兽装备。
-- ●装备怪兽的攻击力变成和这张卡的攻击力相同。
-- ●装备怪兽的属性也当作和这张卡的属性相同属性使用。
-- ●装备怪兽攻击的伤害步骤结束时，把这张卡送去墓地才能发动。那只攻击怪兽只再1次可以继续攻击。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽和自己墓地1只超量怪兽为对象才能发动。作为对象的墓地的怪兽当作持有以下效果的装备魔法卡使用给作为对象的场上的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示怪兽的条件函数
function s.tgfilter(c)
	return c:IsFaceup()
end
-- 过滤墓地超量怪兽的条件函数
function s.eqfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果①的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 获取魔法与陷阱区域的空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 检查魔法与陷阱区是否有空位，以及自己场上是否存在可选为对象的表侧表示怪兽
		return ft>0	and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 检查自己墓地是否存在可选为对象的超量怪兽
			and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要装备的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要装备的墓地超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只超量怪兽作为对象
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息为将墓地的卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g:GetFirst(),1,0,0)
end
-- 效果①的执行处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取与当前连锁相关的对象卡片
	local tg=Duel.GetTargetsRelateToChain()
	local tc=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local ec=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc and ec and ec:CheckUniqueOnField(tp) and not ec:IsForbidden() then
		-- 将墓地的超量怪兽作为装备卡装备给场上的怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,ec,tc) then return end
		-- 作为对象的墓地的怪兽当作持有以下效果的装备魔法卡使用给作为对象的场上的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- ●装备怪兽的攻击力变成和这张卡的攻击力相同。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(ec:GetBaseAttack())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_ADD_ATTRIBUTE)
		e3:SetValue(ec:GetAttribute())
		ec:RegisterEffect(e3)
		-- ●装备怪兽攻击的伤害步骤结束时，把这张卡送去墓地才能发动。那只攻击怪兽只再1次可以继续攻击。
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e4:SetCode(EVENT_DAMAGE_STEP_END)
		e4:SetRange(LOCATION_SZONE)
		e4:SetCondition(s.cacon)
		e4:SetTarget(s.catg)
		e4:SetOperation(s.caop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e4)
	end
end
-- 装备限制条件函数，限制只能装备给指定的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 装备怪兽追加的攻击效果的发动条件判断
function s.cacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前进行攻击的怪兽是否为该装备卡的装备怪兽
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 装备怪兽追加的攻击效果的发动准备与代价处理
function s.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then return c:IsAbleToGraveAsCost() and tc:IsChainAttackable() end
	-- 将作为装备卡的这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(c,REASON_COST)
	-- 将装备怪兽设为效果处理的对象
	Duel.SetTargetCard(tc)
end
-- 装备怪兽追加的攻击效果的执行处理
function s.caop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的装备怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToBattle() then return end
	-- 使该怪兽可以再进行1次攻击
	Duel.ChainAttack()
end

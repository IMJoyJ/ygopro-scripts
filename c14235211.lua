--暴風竜の防人
-- 效果：
-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给自己场上1只龙族的通常怪兽装备。这张卡当作装备卡使用而装备中的场合，装备怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，这张卡的装备怪兽被破坏的场合，作为代替把这张卡破坏。
function c14235211.initial_effect(c)
	-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给自己场上1只龙族的通常怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14235211,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c14235211.eqtg)
	e1:SetOperation(c14235211.eqop)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 此外，这张卡的装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 筛选可作为装备对象的卡：表侧表示且为龙族通常怪兽。
function c14235211.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL)
end
-- 发动效果的前期判定：若检查指定的对象则须是我方场上的表侧龙族通常怪兽；若为效果发动条件判定则需魔陷区有空位且我方场上有符合条件的龙族通常怪兽可供选择。
function c14235211.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14235211.filter(chkc) end
	-- 判定条件之一：自己的魔法与陷阱区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定条件之二：我方场上存在1只以上表侧龙族通常怪兽，且能够成为效果对象。
		and Duel.IsExistingTarget(c14235211.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡（HINTMSG_EQUIP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从我方场上选择1只符合条件的龙族通常怪兽作为装备对象，并注册为效果对象。
	Duel.SelectTarget(tp,c14235211.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：确认此卡仍与效果关联且未被里侧表示等状态影响后，取得装备对象；若魔陷区无空位、目标控制者/表示形式/关联状态异常，则将自身送去墓地；否则将此卡装备给目标，并为装备中的此卡添加只能装备给该对象的限制。
function c14235211.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取效果发动时选择的那1只装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断装备处理是否仍能继续：魔陷区是否有空位、目标是否仍为我方控制、是否表侧表示、是否与效果存在关联；任一不满足则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给选择的龙族通常怪兽。
	Duel.Equip(tp,c,tc)
	-- 对应效果原文'给自己场上1只龙族的通常怪兽装备'，通过EFFECT_EQUIP_LIMIT锁定装备对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c14235211.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制装备对象：仅当目标卡与记录的装备对象一致时才允许继续装备，防止转移到其他怪兽身上。
function c14235211.eqlimit(e,c)
	return c==e:GetLabelObject()
end

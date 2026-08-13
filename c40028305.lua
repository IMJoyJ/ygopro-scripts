--超重武者装留シャイン・クロー
-- 效果：
-- 「超重武者装留 光爪」的②的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作攻击力·守备力上升500的装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗破坏。
-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
function c40028305.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作攻击力·守备力上升500的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c40028305.eqtg)
	e1:SetOperation(c40028305.eqop)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断卡片是否为表侧表示且属于「超重武者」系列，用于选择自己场上符合条件的装备对象。
function c40028305.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 目标选择函数：进行取对象检查与选择。若为连锁中的对象确认，则校验对象位于主要怪兽区、由自己控制且满足eqfilter；若为发动合法性检查，则确认魔陷区有空位且存在可选的装备对象。
function c40028305.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40028305.eqfilter(chkc) end
	-- 在效果发动的合法性检查（chk==0）中，判断自己魔陷区是否有空位，以决定能否发动装备效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 继续合法性检查：确认自己场上存在至少1只表侧表示且属于「超重武者」的怪兽，可作为此装备效果的取对象目标。
		and Duel.IsExistingTarget(c40028305.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送选择提示消息，提示内容为“请选择要装备的卡”（HINTMSG_EQUIP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只满足eqfilter条件的「超重武者」怪兽，并将其设为当前连锁的对象（同时排除效果发动者自身）。
	Duel.SelectTarget(tp,c40028305.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：若发动卡不在应处位置则终止；取得装备对象后，若魔陷区空位不足、对象已失控或变成里侧或与效果失去关联，则将此卡送去墓地；否则将此卡装备给对象，并注册装备限定、攻防上升500、不被战斗破坏以及②特殊召唤效果。
function c40028305.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的装备对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 判断装备处理是否无法进行：魔陷区没有空位、对象被对方控制、对象变成里侧表示或对象与本次效果失去关联时，转入失败处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因无法正常装备，将此卡（光爪）以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽，完成装备动作。
	Duel.Equip(tp,c,tc)
	-- 给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c40028305.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 装备怪兽不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 「超重武者装留 光爪」的②的效果1回合只能使用1次。②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,40028305)
	e5:SetTarget(c40028305.sptg)
	e5:SetOperation(c40028305.spop)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
end
-- 装备限制函数：只有当尝试装备的目标卡为当初指定的对象（LabelObject）时才允许装备，即限定只能装备给那只自己怪兽。
function c40028305.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果的发动条件检查：此卡处于魔陷区（即作为装备卡装备中），且自己主要怪兽区有空位，同时该卡本身满足特殊召唤条件时才能发动。
function c40028305.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查中，判断自己主要怪兽区是否有空位，以确保后续特殊召唤能够执行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作信息为特殊召唤，对象为这张卡自身，数量为1，供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理函数：确认这张卡仍与效果相关后，由操作玩家将其自身表侧表示特殊召唤到自己场上。
function c40028305.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行特殊召唤：将这张卡以表侧表示特殊召唤到其控制者（tp）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

--超重武者装留ダブル・ホーン
-- 效果：
-- 「超重武者装留 双角」的②的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
function c14624296.initial_effect(c)
	-- 对应①效果原文：‘①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽在同1次的战斗阶段中可以作2次攻击。’
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c14624296.eqtg)
	e1:SetOperation(c14624296.eqop)
	c:RegisterEffect(e1)
end
-- 过滤出表侧表示且属于「超重武者」字段的怪兽，用于选择装备对象。
function c14624296.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果发动时的目标检查与选择：确认自己魔陷区有空位，且自己场上存在表侧表示的「超重武者」怪兽可以作为对象。
function c14624296.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14624296.eqfilter(chkc) end
	-- 检查自己魔陷区是否有空位，以决定能否把这张卡装备到怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己场上存在1只满足条件的「超重武者」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c14624296.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示‘请选择要装备的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「超重武者」怪兽作为装备对象，并将其设为效果对象。
	Duel.SelectTarget(tp,c14624296.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：将这张卡装备给对象怪兽；若装备成功，依次赋予装备限制、额外攻击次数，并注册②效果（装备中可特殊召唤自身）。若无法装备则送去墓地。
function c14624296.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否仍然满足（魔陷区有空位、对象仍在我方场上且表侧表示、与效果关联），否则进入失败处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因无法装备，将这张卡以效果原因送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 对应①效果原文中‘从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备’的装备对象限制实现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c14624296.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 对应①效果原文：‘装备怪兽在同1次的战斗阶段中可以作2次攻击。’
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对应效果原文：‘「超重武者装留 双角」的②的效果1回合只能使用1次。②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。’
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,14624296)
	e3:SetTarget(c14624296.sptg)
	e3:SetOperation(c14624296.spop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 装备限制条件：只有发动时选择的那只对象怪兽（LabelObject）可以装备这张卡。
function c14624296.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果发动条件：自己主要怪兽区有空位，且这张装备卡能够被特殊召唤。
function c14624296.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次特殊召唤的操作信息，表明将特殊召唤这张卡（供连锁检测等使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在场上且与效果关联，则将其特殊召唤。
function c14624296.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张装备卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

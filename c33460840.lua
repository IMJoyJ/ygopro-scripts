--巨竜の守護騎士
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值的一半。
-- ③：把自己场上1只怪兽和这张卡解放，以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c33460840.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33460840.eqtg)
	e1:SetOperation(c33460840.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：把自己场上1只怪兽和这张卡解放，以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c33460840.spcost)
	e3:SetTarget(c33460840.sptg)
	e3:SetOperation(c33460840.spop)
	c:RegisterEffect(e3)
end
-- 筛选可作为装备卡的怪兽：龙族、等级7或8、且不是禁止装备的卡。
function c33460840.filter(c,ec)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and not c:IsForbidden()
end
-- ①效果的发动条件：自己魔陷区有空位，且手卡·墓地存在至少1只满足filter的7·8星龙族怪兽。
function c33460840.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位，用于放置装备魔法卡（若没有空位则不能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己手卡·墓地是否存在满足filter条件的7·8星龙族怪兽（至少1只）。
		and Duel.IsExistingMatchingCard(c33460840.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
end
-- ①效果的处理：从手卡·墓地选择1只符合条件的龙族怪兽装备给这张卡，并在装备成功后根据该怪兽的攻击力/守备力为这张卡设置对应的数值提升效果。
function c33460840.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前再次确认：魔陷区仍有空位、此卡表侧表示且仍与此效果关联，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 弹出选择提示，让玩家选择要装备的怪兽（显示“请选择要装备的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己手卡·墓地选择1只满足filter且不受“王家长眠之谷”影响的7·8星龙族怪兽（不选择此卡自身）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33460840.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c)
	local tc=g:GetFirst()
	-- 若未选择到怪兽或装备失败，则终止处理。
	if not (tc and Duel.Equip(tp,tc,c)) then return end
	local atk=math.ceil(tc:GetTextAttack()/2)
	local def=math.ceil(tc:GetTextDefense()/2)
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	-- ①：从自己的手卡·墓地选1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c33460840.eqlimit)
	tc:RegisterEffect(e1)
	if atk>0 then
		-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值的一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
	if def>0 then
		-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值的一半。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(def)
		tc:RegisterEffect(e3)
	end
end
-- 定义装备限制条件：只有效果的所有者（这张守护骑士）才能装备该卡，防止装备卡被转移到其他怪兽身上。
function c33460840.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 筛选③效果的特殊召唤对象：自己墓地的7·8星龙族怪兽，且可以被玩家tp以效果e特殊召唤（满足召唤条件与苏生限制）。
function c33460840.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动代价：解放这张卡和场上另外1只怪兽作为COST，随后从墓地选择对象进行特殊召唤。
function c33460840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查代价可行性：此卡本身可以被解放，并且自己场上存在至少1只其他可解放的怪兽。
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroup(tp,nil,1,c) end
	-- 选择自己场上1只除这张卡以外的可解放怪兽，作为解放代价的一部分。
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,c)
	rg:AddCard(c)
	-- 将选择的怪兽与这张卡一起解放（REASON_COST），作为发动③的代价。
	Duel.Release(rg,REASON_COST)
end
-- ③的发动条件与对象选择：因解放会空出2个怪兽区，因此检查怪兽区可用空间，并选择自己墓地1只7·8星龙族怪兽作为特殊召唤对象。
function c33460840.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33460840.spfilter(chkc,e,tp) end
	-- 检查怪兽区可用空间：发动时会解放这张卡和另1只怪兽，解放后至少空出2个位置，因此允许可用数大于-2。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 检查自己墓地是否存在1只满足spfilter的龙族怪兽，作为特殊召唤的对象候选。
		and Duel.IsExistingTarget(c33460840.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示，让玩家选择要特殊召唤的墓地怪兽（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter的龙族怪兽，并将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c33460840.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：本次效果将进行特殊召唤，对象为已选择的g，数量1，由玩家tp控制。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③的效果处理：将取得对象的墓地龙族怪兽表侧攻击表示特殊召唤到自己场上。
function c33460840.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁中选择的对象卡（即目标墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤到自己场上，并遵守召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

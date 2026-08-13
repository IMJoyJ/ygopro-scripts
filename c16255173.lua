--The grand JUPITER
-- 效果：
-- ①：1回合1次，丢弃2张手卡，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力数值。
-- ③：自己·对方的结束阶段，以这张卡的效果装备的1张怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
function c16255173.initial_effect(c)
	-- ①：1回合1次，丢弃2张手卡，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备。②：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16255173,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16255173.eqcost)
	e1:SetTarget(c16255173.eqtg)
	e1:SetOperation(c16255173.eqop)
	c:RegisterEffect(e1)
	-- ③：自己·对方的结束阶段，以这张卡的效果装备的1张怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16255173,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(c16255173.sptg)
	e2:SetOperation(c16255173.spop)
	c:RegisterEffect(e2)
end
-- 代价函数：确认并执行丢弃2张手卡作为发动①的代价。
function c16255173.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认：检查手牌中是否存在至少2张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	-- 执行代价：从手牌选择2张卡以“代价+丢弃”的理由丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 对象筛选条件：对方场上的表侧表示怪兽且能够改变控制权，才能作为①的装备对象。
function c16255173.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 目标函数：选择对方场上1只满足条件的表侧表示怪兽作为①的对象，并确认我方魔陷区有空位。
function c16255173.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c16255173.eqfilter(chkc) end
	-- 检查我方魔陷区是否有空闲区域，以便将对象怪兽装备到魔陷区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方怪兽区域是否存在可作为①对象的表侧表示怪兽。
		and Duel.IsExistingTarget(c16255173.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“选择要装备的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择对方场上1只符合条件的怪兽，并将其登记为①的效果对象。
	local g=Duel.SelectTarget(tp,c16255173.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将对象怪兽装备为这张卡的装备卡，并赋予其原本攻击力数值的攻击力上升效果，同时设置只能装备给这张卡的限制。
function c16255173.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER)) then return end
	local atk=tc:GetTextAttack()
	if tc:IsFacedown() or atk<0 then atk=0 end
	-- 尝试将对象怪兽作为这张卡的装备卡装备；若装备失败则终止处理。
	if not Duel.Equip(tp,tc,c) then return end
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- 那只表侧表示怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c16255173.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	tc:RegisterFlagEffect(16255173,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 装备限制条件：只有效果的所有者（这张卡本身）才能装备这张怪兽卡。
function c16255173.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 特殊召唤对象筛选：该卡带有本卡效果标记、当前装备给这张卡，并且可以被特殊召唤。
function c16255173.spfilter(c,e,tp,ec)
	return c:GetFlagEffect(16255173)~=0 and c:GetEquipTarget()==ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：在结束阶段选择以这张卡效果装备的1只怪兽卡作为③的对象，并确认我方主怪兽区有空位。
function c16255173.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c16255173.spfilter(chkc,e,tp,c) end
	-- 检查我方主怪兽区是否存在空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方魔陷区是否存在满足条件的装备怪兽卡可以作为③的对象。
		and Duel.IsExistingTarget(c16255173.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,c) end
	-- 向玩家显示“选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只符合条件的装备怪兽，并将其登记为③的效果对象。
	local g=Duel.SelectTarget(tp,c16255173.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,c)
	-- 设置操作信息：即将对对象进行特殊召唤，用于连锁/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将③选择的对象怪兽特殊召唤到我方场上。
function c16255173.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

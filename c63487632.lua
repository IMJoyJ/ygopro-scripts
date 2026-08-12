--ドラグニティアームズ－レヴァテイン
-- 效果：
-- ①：这张卡可以把有「龙骑兵团」卡装备的自己场上1只怪兽除外，从手卡·墓地特殊召唤。
-- ②：这张卡召唤·特殊召唤成功时，以「龙骑兵团武器-灾魔剑」以外的自己墓地1只龙族怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ③：这张卡被对方的效果送去墓地时，以给这张卡装备的自己·对方的墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c63487632.initial_effect(c)
	-- ①：这张卡可以把有「龙骑兵团」卡装备的自己场上1只怪兽除外，从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c63487632.spcon)
	e1:SetTarget(c63487632.sptg)
	e1:SetOperation(c63487632.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功时，以「龙骑兵团武器-灾魔剑」以外的自己墓地1只龙族怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63487632,0))  --"装备"
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c63487632.eqtg)
	e2:SetOperation(c63487632.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方的效果送去墓地时，以给这张卡装备的自己·对方的墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c63487632.eqcheck)
	c:RegisterEffect(e4)
	-- ③：这张卡被对方的效果送去墓地时，以给这张卡装备的自己·对方的墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(63487632,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c63487632.spcon2)
	e5:SetTarget(c63487632.sptg2)
	e5:SetOperation(c63487632.spop2)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 过滤自身特殊召唤所需除外的、装备有「龙骑兵团」卡片的自己场上怪兽
function c63487632.spfilter(c,tp)
	return c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x29) and c:IsAbleToRemoveAsCost()
		-- 判断该怪兽除外后，是否能空出可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定，检查场上是否存在满足除外条件的怪兽
function c63487632.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足除外条件的怪兽
	return Duel.IsExistingMatchingCard(c63487632.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的准备操作，选择自己场上1只满足条件的怪兽
function c63487632.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足除外条件的怪兽组
	local g=Duel.GetMatchingGroup(c63487632.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作，除外选中的怪兽
function c63487632.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽因特殊召唤原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤自己墓地中「龙骑兵团武器-灾魔剑」以外的、可以当作装备卡使用的龙族怪兽
function c63487632.filter(c)
	return not c:IsCode(63487632) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 装备效果的发动准备，检查魔法与陷阱区域空位并选择墓地的龙族怪兽作为对象
function c63487632.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63487632.filter(chkc) end
	-- 在发动效果的第一阶段，检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并检查自己墓地是否存在可以作为对象的龙族怪兽
		and Duel.IsExistingTarget(c63487632.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只满足条件的龙族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63487632.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理的操作信息，表示此效果涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的执行，将作为对象的墓地怪兽当作装备卡装备给这张卡，并添加装备限制
function c63487632.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c63487632.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制函数，规定该装备卡只能装备给这张卡，且在这张卡效果无效时失去装备资格
function c63487632.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 在卡片离开场前，获取并保存当前装备的所有怪兽卡组，以便后续效果使用
function c63487632.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
-- 特殊召唤效果的发动条件判定，检查是否是被对方的效果从怪兽区域送去墓地
function c63487632.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤可以进行特殊召唤的怪兽
function c63487632.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，从离场前保存的装备怪兽中选择1只作为对象
function c63487632.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():GetLabelObject()
	if chkc then return g:IsContains(chkc) and c63487632.spfilter2(chkc,e,tp) end
	-- 在发动效果的第一阶段，检查自己的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(c63487632.spfilter2,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:FilterSelect(tp,c63487632.spfilter2,1,1,nil,e,tp)
	-- 将选中的怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理的操作信息，表示此效果包含特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 特殊召唤效果的执行，将作为对象的怪兽特殊召唤到场上
function c63487632.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

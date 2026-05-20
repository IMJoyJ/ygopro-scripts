--巨竜の聖騎士
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组把1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
-- ②：有装备卡装备的这张卡不受其他怪兽的效果影响。
-- ③：把自己场上1只怪兽和这张卡解放，以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c6075801.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组把1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c6075801.eqtg)
	e1:SetOperation(c6075801.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：有装备卡装备的这张卡不受其他怪兽的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(c6075801.eqcon)
	e3:SetValue(c6075801.efilter)
	c:RegisterEffect(e3)
	-- ③：把自己场上1只怪兽和这张卡解放，以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c6075801.spcost)
	e4:SetTarget(c6075801.sptg)
	e4:SetOperation(c6075801.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：手卡·卡组中可以作为装备卡装备的7·8星龙族怪兽
function c6075801.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and not c:IsForbidden()
end
-- 装备效果的发动条件与靶向检查函数
function c6075801.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查时，确认此卡仍存在于场上，且自己魔陷区有空位
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己的手卡或卡组中存在至少1只满足条件的7·8星龙族怪兽
		and Duel.IsExistingMatchingCard(c6075801.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e:GetHandler()) end
end
-- 装备效果的处理函数：从手卡·卡组选择1只满足条件的龙族怪兽给此卡装备，并添加装备限制
function c6075801.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，若魔陷区无空位、此卡变为里侧表示或已离场，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己的手卡或卡组选择1只满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c6075801.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽作为装备卡装备给此卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c6075801.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：该装备卡只能装备给此卡
function c6075801.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 免疫效果的启用条件：此卡有装备卡装备
function c6075801.eqcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg:GetCount()>0
end
-- 免疫效果的过滤条件：不受其他怪兽发动或持有的效果影响
function c6075801.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 过滤条件：墓地中可以特殊召唤的7·8星龙族怪兽
function c6075801.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动代价处理函数：解放此卡和自己场上的另1只怪兽
function c6075801.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动代价检查时，确认此卡可解放，且场上还存在至少1只其他可解放的怪兽
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroup(tp,nil,1,c) end
	-- 选择场上除此卡以外的1只怪兽作为解放对象
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,c)
	rg:AddCard(c)
	-- 将选中的怪兽和此卡一同解放
	Duel.Release(rg,REASON_COST)
end
-- 特殊召唤效果的靶向/发动条件检查函数：选择墓地中的1只7·8星龙族怪兽为对象
function c6075801.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c6075801.spfilter(chkc,e,tp) end
	-- 在发动条件检查时，确认解放2只怪兽后，自己场上有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 并且自己墓地存在至少1只满足特殊召唤条件的7·8星龙族怪兽
		and Duel.IsExistingTarget(c6075801.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的7·8星龙族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c6075801.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：包含特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理函数：将作为对象的墓地怪兽特殊召唤
function c6075801.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

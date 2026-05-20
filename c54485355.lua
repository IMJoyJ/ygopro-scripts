--昇華騎士－エクスパラディン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡·卡组选1只战士族·炎属性怪兽或者二重怪兽当作攻击力上升500的装备卡使用给这张卡装备。
-- ②：有二重怪兽装备的这张卡被对方破坏的场合才能发动。那些装备的二重怪兽从墓地尽可能往自己场上特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
function c54485355.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡·卡组选1只战士族·炎属性怪兽或者二重怪兽当作攻击力上升500的装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,54485355)
	e1:SetTarget(c54485355.eqtg)
	e1:SetOperation(c54485355.eqop)
	c:RegisterEffect(e1)
	local e2=Effect.Clone(e1)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：有二重怪兽装备的这张卡被对方破坏的场合才能发动。那些装备的二重怪兽从墓地尽可能往自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c54485355.eqcheck)
	c:RegisterEffect(e4)
	-- ②：有二重怪兽装备的这张卡被对方破坏的场合才能发动。那些装备的二重怪兽从墓地尽可能往自己场上特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,54485356)
	e3:SetCondition(c54485355.spcon)
	e3:SetTarget(c54485355.sptg)
	e3:SetOperation(c54485355.spop)
	e3:SetLabelObject(e4)
	c:RegisterEffect(e3)
end
-- 过滤手卡·卡组中可以装备的战士族·炎属性怪兽或二重怪兽
function c54485355.eqfilter(c,tp)
	return (c:IsType(TYPE_DUAL) or (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE))) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 装备效果的发动检测与目标确认
function c54485355.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡或卡组是否存在满足装备条件的怪兽
		and Duel.IsExistingMatchingCard(c54485355.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 装备效果的执行，选择怪兽装备并赋予攻击力上升和装备限制效果
function c54485355.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否有空位，没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 提示玩家选择要装备的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从手卡或卡组选择1张满足条件的怪兽卡
		local g=Duel.SelectMatchingCard(tp,c54485355.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,tp)
		local tc=g:GetFirst()
		-- 将选中的怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作...装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(c)
		e1:SetValue(c54485355.eqlimit)
		tc:RegisterEffect(e1)
		-- 攻击力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 限制装备卡只能装备给当前怪兽
function c54485355.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 在怪兽离场前，记录并保存其当前装备的卡片组
function c54485355.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
-- 过滤墓地中可以特殊召唤的二重怪兽
function c54485355.spfilter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_GRAVE)
end
-- 检查是否是由对方破坏且之前在怪兽区域存在
function c54485355.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的发动检测与目标确认
function c54485355.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(c54485355.spfilter,1,nil,e,tp) end
	local sg=g:Filter(c54485355.spfilter,nil,e,tp)
	-- 将要特殊召唤的怪兽卡组设置为效果处理对象
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- 过滤墓地中与效果关联且可以特殊召唤的二重怪兽
function c54485355.spfilter2(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
end
-- 特殊召唤效果的执行，将原本装备的二重怪兽尽可能特殊召唤并使其处于再1次召唤的状态
function c54485355.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=e:GetLabelObject():GetLabelObject()
	-- 筛选出不受王家长眠之谷影响且可以特殊召唤的二重怪兽
	local sg=g:Filter(aux.NecroValleyFilter(c54485355.spfilter2),nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local spg=sg:Select(tp,ft,ft,nil)
	if spg:GetCount()>0 then
		local tc=spg:GetFirst()
		while tc do
			-- 尝试将怪兽以表侧表示特殊召唤，并判断是否成功
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				tc:EnableDualState()
			end
			tc=spg:GetNext()
		end
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end

--絶火の大賢者ゾロア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从额外卡组把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
-- ②：让这张卡把「大贤者」怪兽卡装备的场合才能发动。从自己的手卡·墓地把「绝火之大贤者 琐罗亚」以外的1只魔法师族·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36099130.initial_effect(c)
	-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从额外卡组把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36099130,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,36099130)
	e1:SetTarget(c36099130.eqtg)
	e1:SetOperation(c36099130.eqop)
	c:RegisterEffect(e1)
	-- ②：让这张卡把「大贤者」怪兽卡装备的场合才能发动。从自己的手卡·墓地把「绝火之大贤者 琐罗亚」以外的1只魔法师族·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36099130,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_EQUIP)
	e2:SetCountLimit(1,36099131)
	e2:SetCondition(c36099130.spcon)
	e2:SetTarget(c36099130.sptg)
	e2:SetOperation(c36099130.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选额外卡组中满足条件的「大贤者」怪兽（不被禁止且在场上有唯一性）
function c36099130.eqfilter(c,tp)
	return c:IsSetCard(0x150) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤函数，用于筛选自己场上满足条件的「大贤者」怪兽（表侧表示）
function c36099130.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 效果处理时的条件判断函数，检查是否满足发动条件（场上存在目标怪兽、额外卡组存在可装备怪兽）
function c36099130.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36099130.cfilter(chkc) end
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在满足条件的「大贤者」怪兽
		and Duel.IsExistingTarget(c36099130.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查额外卡组是否存在满足条件的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c36099130.eqfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上满足条件的「大贤者」怪兽作为装备对象
	Duel.SelectTarget(tp,c36099130.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的处理函数，执行装备操作
function c36099130.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从额外卡组中选择一张满足条件的「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,c36099130.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local sc=g:GetFirst()
		-- 执行装备操作，若失败则返回
		if not sc or not Duel.Equip(tp,sc,tc) then return end
		-- 设置装备限制效果，使装备卡只能装备给特定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(c36099130.eqlimit)
		sc:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，确保只能装备给指定怪兽
function c36099130.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤函数，用于筛选装备卡的原始类型为怪兽且为「大贤者」的卡
function c36099130.cfilter2(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsSetCard(0x150)
end
-- 触发效果的条件判断函数，检查是否有装备卡被装备
function c36099130.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36099130.cfilter2,1,nil)
end
-- 过滤函数，用于筛选满足条件的魔法师族·4星怪兽（非本卡）
function c36099130.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(36099130)
end
-- 特殊召唤效果的处理函数，检查是否满足发动条件
function c36099130.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在满足条件的魔法师族·4星怪兽
		and Duel.IsExistingMatchingCard(c36099130.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，告知连锁中将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数，执行特殊召唤操作
function c36099130.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或墓地中选择一张满足条件的魔法师族·4星怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36099130.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g<1 then return end
		local tc=g:GetFirst()
		-- 执行特殊召唤步骤，若成功则继续设置效果无效化
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 设置效果无效化，使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 设置效果无效化，使特殊召唤的怪兽效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end

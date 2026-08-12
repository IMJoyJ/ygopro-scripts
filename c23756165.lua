--魅惑の女王 LV5
-- 效果：
-- ①：这张卡是已用「魅惑的女王 LV3」的效果特殊召唤的场合，1回合1次，以对方场上1只5星以下的怪兽为对象才能发动。那只5星以下的对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
-- ③：自己准备阶段，把用这张卡的效果把怪兽装备的这张卡送去墓地才能发动。从手卡·卡组把1只「魅惑的女王 LV7」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤成功时的标记、装备效果（一速）、装备效果（二速）、特殊召唤效果
function c23756165.initial_effect(c)
	-- 记录该卡与「魅惑的女王 LV3」和「魅惑的女王 LV7」的关联，用于效果判断
	aux.AddCodeList(c,87257460,50140163)
	-- ①：这张卡是已用「魅惑的女王 LV3」的效果特殊召唤的场合，1回合1次，以对方场上1只5星以下的怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c23756165.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已用「魅惑的女王 LV3」的效果特殊召唤的场合，1回合1次，以对方场上1只5星以下的怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23756165,0))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c23756165.eqcon1)
	e2:SetTarget(c23756165.eqtg)
	e2:SetOperation(c23756165.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c23756165.eqcon2)
	c:RegisterEffect(e3)
	-- ③：自己准备阶段，把用这张卡的效果把怪兽装备的这张卡送去墓地才能发动。从手卡·卡组把1只「魅惑的女王 LV7」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23756165,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCondition(c23756165.spcon)
	e4:SetCost(c23756165.spcost)
	e4:SetTarget(c23756165.sptg)
	e4:SetOperation(c23756165.spop)
	c:RegisterEffect(e4)
end
c23756165.lvup={50140163,87257460}
c23756165.lvdn={87257460}
-- 当此卡被特殊召唤成功时，若其来源为「魅惑的女王 LV3」，则标记此卡已使用过LV3效果
function c23756165.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSpecialSummonInfo(SUMMON_INFO_CODE)==87257460 then
		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 装备效果一速发动条件：此卡已使用过LV3效果且未装备怪兽，且当前不在对方的即时效果影响下
function c23756165.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 装备效果一速发动条件：此卡已使用过LV3效果且未装备怪兽，且当前不在对方的即时效果影响下
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and not aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 装备效果二速发动条件：此卡已使用过LV3效果且未装备怪兽，且当前在对方的即时效果影响下
function c23756165.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 装备效果二速发动条件：此卡已使用过LV3效果且未装备怪兽，且当前在对方的即时效果影响下
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 筛选5星以下且正面表示的对方怪兽，用于装备效果的目标选择
function c23756165.filter(c)
	return c:IsLevelBelow(5) and c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 装备效果目标选择函数：选择对方场上满足条件的怪兽作为装备对象
function c23756165.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c23756165.filter(chkc) end
	-- 判断装备效果是否可以发动：场上是否有空余的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断装备效果是否可以发动：对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c23756165.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上满足条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c23756165.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制效果：只有装备者自身可以装备此卡
function c23756165.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果执行函数：将目标怪兽装备给此卡，并设置装备限制和替代破坏效果
function c23756165.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		local def=tc:GetTextDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 尝试将目标怪兽装备给此卡，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- 设置装备限制效果：只有装备者自身可以装备此卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c23756165.eqlimit)
		tc:RegisterEffect(e1)
		-- 设置替代破坏效果：当此卡被战斗破坏时，可由装备的怪兽代替破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c23756165.repval)
		tc:RegisterEffect(e2)
	end
end
-- 替代破坏效果值函数：当破坏原因为战斗时，此卡可被替代破坏
function c23756165.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 特殊召唤效果发动条件：当前为己方准备阶段且此卡已装备怪兽
function c23756165.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤效果发动条件：当前为己方准备阶段且此卡已装备怪兽
	return Duel.GetTurnPlayer()==tp and aux.IsSelfEquip(e:GetHandler(),FLAG_ID_ALLURE_QUEEN)
end
-- 特殊召唤效果消耗函数：将此卡送去墓地作为发动代价
function c23756165.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选「魅惑的女王 LV7」卡，用于特殊召唤
function c23756165.spfilter(c,e,tp)
	return c:IsCode(50140163) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_LV,tp,true,false)
end
-- 特殊召唤效果目标选择函数：选择满足条件的「魅惑的女王 LV7」卡
function c23756165.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断特殊召唤效果是否可以发动：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断特殊召唤效果是否可以发动：手牌或卡组中是否存在满足条件的「魅惑的女王 LV7」
		and Duel.IsExistingMatchingCard(c23756165.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果执行函数：选择并特殊召唤「魅惑的女王 LV7」
function c23756165.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断特殊召唤是否可以发动：场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「魅惑的女王 LV7」卡
	local g=Duel.SelectMatchingCard(tp,c23756165.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end

--シャルルの叙事詩
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1张「圣剑」装备魔法卡给对方观看，从手卡·卡组把1只「焰圣骑士」怪兽特殊召唤。那之后，给人观看的卡给那只怪兽装备或送去墓地。
-- ②：把墓地的这张卡除外，以自己场上1只「焰圣骑士帝-查理」为对象才能发动。从手卡·卡组选1只「圣骑士」怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果，分别为①和②效果
function s.initial_effect(c)
	-- 记录该卡拥有「焰圣骑士帝-查理」的卡名
	aux.AddCodeList(c,77656797)
	-- ①效果：将手卡1张「圣剑」装备魔法卡给对方观看，从手卡·卡组把1只「焰圣骑士」怪兽特殊召唤。那之后，给人观看的卡给那只怪兽装备或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②效果：把墓地的这张卡除外，以自己场上1只「焰圣骑士帝-查理」为对象才能发动。从手卡·卡组选1只「圣骑士」怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- ②效果的发动费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在「圣剑」装备魔法卡且未公开
function s.cfilter0(c)
	return c:IsSetCard(0x207a) and c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and not c:IsPublic()
end
-- 过滤函数，用于判断手卡中是否存在满足条件的「圣剑」装备魔法卡，并且能配合后续的「焰圣骑士」怪兽特殊召唤
function s.cfilter(c,e,tp,ft)
	-- 返回s.cfilter0(c)和Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c,ft)的逻辑与结果
	return s.cfilter0(c) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c,ft)
end
-- 过滤函数，用于判断是否能特殊召唤「焰圣骑士」怪兽
function s.spfilter(c,e,tp,ec,ft)
	if not c:IsSetCard(0x507a) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if ec:IsAbleToGrave() then
		return true
	else
		return ft>0 and ec:CheckEquipTarget(c) and ec:CheckUniqueOnField(tp) and not ec:IsForbidden()
	end
end
-- ①效果的发动条件判断函数，检查是否有足够的场地和满足条件的装备卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取玩家tp在SZONE的可用区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE) then
			ft=ft-1
		end
		-- 检查玩家tp在MZONE是否有可用区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家tp手卡中是否存在满足条件的装备卡
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ft)
	end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的发动处理函数，执行特殊召唤和装备/送墓选择
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp在SZONE的可用区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择要确认的装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的装备卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ft)
	if #g>0 then
		local tc=g:GetFirst()
		-- 向对方确认装备卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 检查是否有足够的MZONE区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「焰圣骑士」怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc,ft)
		-- 执行特殊召唤操作，若成功则继续处理装备或送墓选项
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 重新获取玩家tp在SZONE的可用区域数量
			ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local sc=sg:GetFirst()
			local b1=sc:IsFaceup() and sc:IsLocation(LOCATION_MZONE) and ft>0
				and tc:CheckEquipTarget(sc) and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			local b2=tc:IsAbleToGrave()
			local off=1
			local ops={}
			local opval={}
			if b1 then
				ops[off]=aux.Stringid(id,2)  --"给那只怪兽装备"
				opval[off]=0
				off=off+1
			end
			if b2 then
				ops[off]=aux.Stringid(id,3)  --"送去墓地"
				opval[off]=1
				off=off+1
			end
			-- 选择装备或送墓选项
			local op=Duel.SelectOption(tp,table.unpack(ops))+1
			local sel=opval[op]
			if sel==0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将装备卡装备给目标怪兽
				Duel.Equip(tp,tc,sc)
			elseif sel==1 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将装备卡送入墓地
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	else
		-- 提示玩家选择要确认的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择满足条件的装备卡
		g=Duel.SelectMatchingCard(tp,s.cfilter0,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 向对方确认装备卡
			Duel.ConfirmCards(1-tp,g)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
		end
	end
end
-- 过滤函数，用于判断是否为表侧表示的「焰圣骑士帝-查理」
function s.charlesfilter(c)
	return c:IsFaceup() and c:IsCode(77656797)
end
-- 过滤函数，用于判断是否为「圣骑士」怪兽且满足装备条件
function s.eqfilter(c,tp)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ②效果的目标选择函数，用于选择「焰圣骑士帝-查理」作为对象
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.charlesfilter(chkc) end
	-- 检查玩家tp在SZONE是否有可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家tp场上是否存在「焰圣骑士帝-查理」
		and Duel.IsExistingTarget(s.charlesfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家tp手卡或卡组中是否存在满足条件的「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的「焰圣骑士帝-查理」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择「焰圣骑士帝-查理」作为目标
	Duel.SelectTarget(tp,s.charlesfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的发动处理函数，执行装备操作
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp在SZONE是否有可用区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc1=Duel.GetFirstTarget()
	if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() then return end
	-- 提示玩家选择要装备的「圣骑士」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc2=g:GetFirst()
		-- 执行装备操作，若成功则注册装备限制和攻击力加成效果
		if Duel.Equip(tp,tc2,tc1,true) then
			local c=e:GetHandler()
			-- 装备限制效果，确保装备卡只能装备给特定怪兽
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(tc1)
			tc2:RegisterEffect(e1)
			-- 装备效果，使装备卡的攻击力上升500
			local e2=Effect.CreateEffect(tc2)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
	end
end
-- 装备限制效果的判断函数，用于限制装备卡只能装备给特定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

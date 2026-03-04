--シャルルの叙事詩
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1张「圣剑」装备魔法卡给对方观看，从手卡·卡组把1只「焰圣骑士」怪兽特殊召唤。那之后，给人观看的卡给那只怪兽装备或送去墓地。
-- ②：把墓地的这张卡除外，以自己场上1只「焰圣骑士帝-查理」为对象才能发动。从手卡·卡组选1只「圣骑士」怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码77656797（焰圣骑士帝-查理）
	aux.AddCodeList(c,77656797)
	-- ①：把手卡1张「圣剑」装备魔法卡给对方观看，从手卡·卡组把1只「焰圣骑士」怪兽特殊召唤。那之后，给人观看的卡给那只怪兽装备或送去墓地。
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
	-- ②：把墓地的这张卡除外，以自己场上1只「焰圣骑士帝-查理」为对象才能发动。从手卡·卡组选1只「圣骑士」怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 检查手牌中是否存在「圣剑」装备魔法卡且满足后续条件
function s.cfilter0(c)
	return c:IsSetCard(0x207a) and c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and not c:IsPublic()
end
-- 检查手牌中是否存在「圣剑」装备魔法卡并满足召唤条件
function s.cfilter(c,e,tp,ft)
	-- 判断是否存在满足召唤条件的「焰圣骑士」怪兽
	return s.cfilter0(c) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c,ft)
end
-- 检查召唤目标是否满足条件
function s.spfilter(c,e,tp,ec,ft)
	if not c:IsSetCard(0x507a) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if ec:IsAbleToGrave() then
		return true
	else
		return ft>0 and ec:CheckEquipTarget(c) and ec:CheckUniqueOnField(tp) and not ec:IsForbidden()
	end
end
-- 设置效果目标函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取玩家场上可用的装备区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE) then
			ft=ft-1
		end
		-- 判断玩家场上是否有可用的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断手牌中是否存在满足条件的「圣剑」装备魔法卡
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ft)
	end
	-- 设置连锁操作信息，表示将特殊召唤和送去墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 设置效果发动函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的装备区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择确认卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 选择满足条件的「圣剑」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ft)
	if #g>0 then
		local tc=g:GetFirst()
		-- 向对方玩家展示所选卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 判断玩家场上是否有可用的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择特殊召唤目标
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的「焰圣骑士」怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc,ft)
		-- 将选中的怪兽特殊召唤
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 重新获取玩家场上可用的装备区域数量
			ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local sc=sg:GetFirst()
			local b1=sc:IsFaceup() and sc:IsLocation(LOCATION_MZONE) and ft>0
				and tc:CheckEquipTarget(sc) and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			local b2=tc:IsAbleToGrave()
			local off=1
			local ops={}
			local opval={}
			if b1 then
				ops[off]=aux.Stringid(id,2)
				opval[off]=0
				off=off+1
			end
			if b2 then
				ops[off]=aux.Stringid(id,3)
				opval[off]=1
				off=off+1
			end
			-- 选择装备或送去墓地的操作
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
				-- 将装备卡送去墓地
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	else
		-- 提示玩家选择确认卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		-- 选择满足条件的「圣剑」装备魔法卡
		g=Duel.SelectMatchingCard(tp,s.cfilter0,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 向对方玩家展示所选卡片
			Duel.ConfirmCards(1-tp,g)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
		end
	end
end
-- 检查场上是否存在「焰圣骑士帝-查理」
function s.charlesfilter(c)
	return c:IsFaceup() and c:IsCode(77656797)
end
-- 检查手牌或卡组中是否存在「圣骑士」怪兽
function s.eqfilter(c,tp)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 设置装备效果目标函数
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.charlesfilter(chkc) end
	-- 判断装备效果是否可以发动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在「焰圣骑士帝-查理」
		and Duel.IsExistingTarget(s.charlesfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断手牌或卡组中是否存在「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择「焰圣骑士帝-查理」作为目标
	Duel.SelectTarget(tp,s.charlesfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 设置装备效果发动函数
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有可用的装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc1=Duel.GetFirstTarget()
	if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() then return end
	-- 提示玩家选择装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择满足条件的「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc2=g:GetFirst()
		-- 将装备卡装备给目标怪兽
		if Duel.Equip(tp,tc2,tc1,true) then
			local c=e:GetHandler()
			-- 设置装备限制效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(tc1)
			tc2:RegisterEffect(e1)
			-- 设置装备卡攻击力上升500的效果
			local e2=Effect.CreateEffect(tc2)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
	end
end
-- 设置装备限制条件函数
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

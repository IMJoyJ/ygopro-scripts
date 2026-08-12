--海晶乙女ワンダーハート
-- 效果：
-- 水属性怪兽2只以上
-- ①：这张卡和怪兽进行战斗的伤害计算时才能发动1次。选给这张卡装备的1张自己的「海晶少女」怪兽卡特殊召唤。这张卡不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。这个效果特殊召唤的怪兽在结束阶段当作装备卡使用给这张卡装备。
-- ②：这张卡被对方破坏的场合才能发动。从自己墓地选1只连接3以下的「海晶少女」怪兽特殊召唤。
function c94207108.initial_effect(c)
	-- 设置连接召唤手续：水属性怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2)
	c:EnableReviveLimit()
	-- ①：这张卡和怪兽进行战斗的伤害计算时才能发动1次。选给这张卡装备的1张自己的「海晶少女」怪兽卡特殊召唤。这张卡不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。这个效果特殊召唤的怪兽在结束阶段当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94207108,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c94207108.spcon1)
	e1:SetCost(c94207108.spcost1)
	e1:SetTarget(c94207108.sptg1)
	e1:SetOperation(c94207108.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合才能发动。从自己墓地选1只连接3以下的「海晶少女」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94207108,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c94207108.spcon2)
	e2:SetTarget(c94207108.sptg2)
	e2:SetOperation(c94207108.spop2)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否正在和怪兽进行战斗（存在战斗对象）
function c94207108.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 伤害计算时效果的发动代价：给自身添加Flag以确保每次伤害计算只能发动1次
function c94207108.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(94207109)==0 end
	c:RegisterFlagEffect(94207109,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 过滤给这张卡装备的、可以特殊召唤的自己的「海晶少女」怪兽卡
function c94207108.spfilter1(c,e,tp,ec)
	return c:IsSetCard(0x12b) and c:GetEquipTarget()==ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 伤害计算时特殊召唤效果的靶向处理（检查怪兽区域空位及是否存在可特召的装备卡，并设置操作信息）
function c94207108.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔法与陷阱区域是否存在满足条件的「海晶少女」装备卡
		and Duel.IsExistingMatchingCard(c94207108.spfilter1,tp,LOCATION_SZONE,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置特殊召唤的操作信息，表示将从魔法与陷阱区域特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
-- 伤害计算时特殊召唤效果的执行：特殊召唤装备的怪兽，并适用战斗不破、伤害为0以及结束阶段重新装备的效果
function c94207108.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1张给这张卡装备的自己的「海晶少女」怪兽卡
	local g=Duel.SelectMatchingCard(tp,c94207108.spfilter1,tp,LOCATION_SZONE,0,1,1,nil,e,tp,c)
	local tc=g:GetFirst()
	-- 将选中的怪兽以表侧表示特殊召唤，若特殊召唤成功则进行后续处理
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(94207108,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc:RegisterFlagEffect(94207108,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c94207108.eqcon(c))
		e1:SetOperation(c94207108.eqop(c))
		-- 注册在结束阶段将该怪兽重新装备给此卡的延迟触发效果
		Duel.RegisterEffect(e1,tp)
	end
	if c:IsRelateToEffect(e) then
		-- 这张卡不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		-- 那次战斗发生的对自己的战斗伤害变成0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册使那次战斗对自己的战斗伤害变成0的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 检查重新装备效果的触发条件，确保此卡与被特召的怪兽在场上且关联标记一致
function c94207108.eqcon(mc)
	return
		-- 闭包函数：验证两张卡是否仍存在于场上且Flag标记匹配，若不匹配则重置该效果
		function (e,tp,eg,ep,ev,re,r,rp)
			local tc=e:GetLabelObject()
			if mc:GetFlagEffectLabel(94207108)~=e:GetLabel() or tc:GetFlagEffectLabel(94207108)~=e:GetLabel() then
				e:Reset()
				return false
			else return true end
		end
end
-- 重新装备效果的具体执行，将特召的怪兽重新作为装备卡装备并设置装备限制
function c94207108.eqop(mc)
	return
		-- 闭包函数：执行装备操作，并为重新装备的卡添加装备对象限制效果
		function (e,tp,eg,ep,ev,re,r,rp)
			local tc=e:GetLabelObject()
			-- 尝试将该怪兽作为装备卡装备给此卡，若装备失败则结束处理
			if not Duel.Equip(tp,tc,mc) then return end
			-- 当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(mc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(c94207108.eqlimit)
			e1:SetLabelObject(mc)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
end
-- 装备限制函数：规定该卡只能装备给此卡
function c94207108.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 检查此卡是否是被对方破坏且原本由自己控制
function c94207108.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤自己墓地中可以特殊召唤的连接3以下的「海晶少女」怪兽
function c94207108.spfilter2(c,e,tp)
	return c:IsSetCard(0x12b) and c:IsLinkBelow(3) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 被破坏时特殊召唤效果的靶向处理（检查怪兽区域空位及墓地中是否存在满足条件的怪兽，并设置操作信息）
function c94207108.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的「海晶少女」怪兽
		and Duel.IsExistingMatchingCard(c94207108.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 被破坏时特殊召唤效果的执行：从墓地选择并特殊召唤1只连接3以下的「海晶少女」怪兽
function c94207108.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择1只满足条件且不受「王家长眠之谷」影响的「海晶少女」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94207108.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--ネクロの魔導書
-- 效果：
-- 把自己墓地1只魔法师族怪兽从游戏中除外，把这张卡以外的手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。选择自己墓地1只魔法师族怪兽表侧攻击表示特殊召唤，把这张卡装备。此外，装备怪兽的等级上升因为这张卡发动而除外的魔法师族怪兽的等级数值。「死灵之魔导书」在1回合只能发动1张。
function c52628687.initial_effect(c)
	-- 创建此卡的发动效果，包含特殊召唤和装备类别，类型为发动效果，自由时点，取对象效果，发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52628687+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c52628687.cost)
	e1:SetTarget(c52628687.target)
	e1:SetOperation(c52628687.operation)
	c:RegisterEffect(e1)
end
-- 设置cost标签为100，表示已支付费用
function c52628687.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数：检查自己墓地是否存在魔法师族且等级大于0、可作为除外费用并能选择特殊召唤的怪兽
function c52628687.cfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:GetLevel()>0 and c:IsAbleToRemoveAsCost()
		-- 确保在选择目标时存在满足条件的魔法师族怪兽可以特殊召唤
		and Duel.IsExistingTarget(c52628687.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤函数：检查自己手牌中是否存在名字带有「魔导书」的魔法卡且未公开
function c52628687.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 过滤函数：检查自己墓地是否存在魔法师族且可特殊召唤为表侧攻击表示的怪兽
function c52628687.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 设置效果目标，检查是否满足发动条件并选择除外墓地魔法师族怪兽、确认手牌魔法卡、选择特殊召唤墓地魔法师族怪兽
function c52628687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52628687.spfilter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地是否存在满足除外费用的魔法师族怪兽
			and Duel.IsExistingMatchingCard(c52628687.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 检查自己手牌是否存在名字带有「魔导书」的魔法卡
			and Duel.IsExistingMatchingCard(c52628687.cffilter,tp,LOCATION_HAND,0,1,e:GetHandler())
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择并获取满足条件的墓地魔法师族怪兽作为除外对象
	local rg=Duel.SelectMatchingCard(tp,c52628687.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的怪兽从游戏中除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 提示玩家选择给对方确认的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择并获取满足条件的手牌魔法卡用于确认
	local cg=Duel.SelectMatchingCard(tp,c52628687.cffilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方确认所选的手牌魔法卡
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择并获取满足条件的墓地魔法师族怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c52628687.spfilter,tp,LOCATION_GRAVE,0,1,1,rg:GetFirst(),e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，确定装备卡的数量和类型
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制函数：确保只有被装备的怪兽才能装备此卡
function c52628687.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 处理效果的发动，判断是否满足条件并执行特殊召唤、装备及等级提升
function c52628687.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽特殊召唤到场上
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 创建一个装备效果，使装备怪兽的等级上升因发动而除外的魔法师族怪兽的等级数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 将此卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 创建一个装备限制效果，确保只有被装备的怪兽才能装备此卡
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabelObject(tc)
		e2:SetValue(c52628687.eqlimit)
		c:RegisterEffect(e2)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end

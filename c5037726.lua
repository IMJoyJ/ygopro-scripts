--光霊術－「聖」
-- 效果：
-- ①：把自己场上1只光属性怪兽解放，以除外的1只自己或者对方的怪兽为对象才能发动。对方可以从手卡把1张陷阱卡给人观看让这个效果无效。没给观看的场合，作为对象的怪兽在自己场上特殊召唤。
function c5037726.initial_effect(c)
	-- ①：把自己场上1只光属性怪兽解放，以除外的1只自己或者对方的怪兽为对象才能发动。对方可以从手卡把1张陷阱卡给人观看让这个效果无效。没给观看的场合，作为对象的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c5037726.cost)
	e1:SetTarget(c5037726.target)
	e1:SetOperation(c5037726.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足光属性且可解放的怪兽
function c5037726.rfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 支付代价：解放1只光属性怪兽
function c5037726.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家场上可用区域数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否可以支付代价
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c5037726.rfilter,1,nil,ft,tp) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c5037726.rfilter,1,1,nil,ft,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 过滤可特殊召唤的除外怪兽
function c5037726.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择1只除外的光属性怪兽
function c5037726.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c5037726.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查是否存在满足条件的除外怪兽
			return Duel.IsExistingTarget(c5037726.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
		else
			-- 检查玩家场上是否有空位
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 同时满足场上空位和存在除外怪兽两个条件
				and Duel.IsExistingTarget(c5037726.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c5037726.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤手牌中未公开的陷阱卡
function c5037726.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_TRAP)
end
-- 处理效果发动：判断是否无效并执行特殊召唤
function c5037726.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可被无效
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取玩家手牌中的陷阱卡
		local g=Duel.GetMatchingGroup(c5037726.cfilter,tp,0,LOCATION_HAND,nil)
		-- 提示对方选择是否确认陷阱卡
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(5037726,0))  --"是否把1张陷阱卡给对方观看？"
		if g:GetCount()>0 then
			-- 选择确认陷阱卡选项
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 若无陷阱卡则默认不确认
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 提示对方选择要确认的陷阱卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 向对方展示所选陷阱卡
			Duel.ConfirmCards(tp,sg)
			-- 洗切对方手牌
			Duel.ShuffleHand(1-tp)
			-- 使效果无效
			Duel.NegateEffect(0)
			return
		end
	end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

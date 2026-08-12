--ファルシオンβ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。
-- ●从自己卡组选择1只攻击力1200以下的机械族·光属性怪兽送去墓地。
-- ●选择自己墓地存在的1只攻击力1200以下的机械族·光属性怪兽特殊召唤。
function c86170989.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。●从自己卡组选择1只攻击力1200以下的机械族·光属性怪兽送去墓地。●选择自己墓地存在的1只攻击力1200以下的机械族·光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86170989,0))  --"选择一个效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(c86170989.target)
	e1:SetOperation(c86170989.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中满足“攻击力1200以下的机械族·光属性”且能送去墓地的怪兽
function c86170989.filter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttackBelow(1200) and c:IsAbleToGrave()
end
-- 过滤墓地中满足“攻击力1200以下的机械族·光属性”且能特殊召唤的怪兽
function c86170989.filter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttackBelow(1200)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与效果分支选择处理
function c86170989.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86170989.filter2(chkc,e,tp) end
	if chk==0 then return true end
	local op=0
	-- 提示玩家选择要发动的效果分支
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(86170989,0))  --"选择一个效果发动"
	-- 检查自己卡组是否存在满足效果1（送墓）条件的怪兽
	local t1=Duel.IsExistingMatchingCard(c86170989.filter1,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否有空余的怪兽区域
	local t2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在满足效果2（特殊召唤）条件的可选择对象
		and Duel.IsExistingTarget(c86170989.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if t1 and t2 then
		-- 当两个效果都满足发动条件时，让玩家选择其中一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(86170989,1),aux.Stringid(86170989,2))+1  --"卡组怪兽送去墓地/墓地怪兽特殊召唤"
	elseif t1 then
		-- 仅满足效果1时，强制选择效果1（送去墓地）
		Duel.SelectOption(tp,aux.Stringid(86170989,1))  --"卡组怪兽送去墓地"
		op=1
	elseif t2 then
		-- 仅满足效果2时，强制选择效果2（特殊召唤）
		Duel.SelectOption(tp,aux.Stringid(86170989,2))  --"墓地怪兽特殊召唤"
		op=2
	end
	e:SetLabel(op)
	if op==2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己墓地1只满足条件的怪兽作为特殊召唤的对象
		local g=Duel.SelectTarget(tp,c86170989.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置连锁信息为特殊召唤选中的怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	elseif op==1 then
		-- 设置连锁信息为从卡组将1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		e:SetProperty(0)
		e:SetCategory(CATEGORY_TOGRAVE)
	else
		e:SetProperty(0)
		e:SetCategory(0)
	end
end
-- 效果解决时的具体操作，根据选择的分支执行送墓或特殊召唤
function c86170989.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==2 then
		-- 获取在发动阶段选择的特殊召唤对象
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==1 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从自己卡组选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c86170989.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽因效果送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

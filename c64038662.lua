--ヴァリュアブル・フォーム
-- 效果：
-- 1回合1次，可以从以下效果选择1个发动。
-- ●选择自己场上2只名字带有「甲虫装机」的怪兽，选择的1只怪兽给另1只怪兽装备。
-- ●选择自己场上1只当作装备卡使用的名字带有「甲虫装机」的怪兽在自己场上表侧守备表示特殊召唤。
function c64038662.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(64038662,0))  --"选择一个效果发动"
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c64038662.eftg)
	e2:SetOperation(c64038662.efop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「甲虫装机」怪兽
function c64038662.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 过滤自己场上表侧表示、当作装备卡使用且可以特殊召唤的「甲虫装机」怪兽
function c64038662.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x56) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时，对已选择的对象进行合法性检查
function c64038662.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then return false
		else return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c64038662.filter2(chkc,e,tp) end
	end
	-- 检查是否满足效果1的发动条件：自己场上有2只以上的「甲虫装机」怪兽，且魔陷区有空位
	local b1=Duel.IsExistingTarget(c64038662.filter1,tp,LOCATION_MZONE,0,2,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	-- 检查是否满足效果2的发动条件：自己场上有当作装备卡使用的「甲虫装机」怪兽，且怪兽区有空位
	local b2=Duel.IsExistingTarget(c64038662.filter2,tp,LOCATION_SZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动其中一个效果
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(64038662,2),1},  --"装备"
		{b2,aux.Stringid(64038662,3),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择自己场上2只「甲虫装机」怪兽作为对象
		Duel.SelectTarget(tp,c64038662.filter1,tp,LOCATION_MZONE,0,2,2,nil)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己场上1只当作装备卡使用的「甲虫装机」怪兽作为对象
		local g=Duel.SelectTarget(tp,c64038662.filter2,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		-- 设置特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理的整体逻辑，根据选择的效果分支分别处理装备或特殊召唤
function c64038662.efop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取仍与该连锁相关的对象卡片
		local g=Duel.GetTargetsRelateToChain()
		if g:FilterCount(Card.IsFaceup,nil)<2 then return end
		-- 检查魔陷区是否有空位，若无则无法装备
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择哪一只怪兽作为装备卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(64038662,4))  --"请选择要当成装备卡的怪兽"
		local tc1=g:Select(tp,1,1,nil):GetFirst()
		local tc2=(g-tc1):GetFirst()
		-- 将选择的怪兽作为装备卡装备给另一只怪兽
		if Duel.Equip(tp,tc1,tc2,false) then
			-- 选择的1只怪兽给另1只怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c64038662.eqlimit)
			e1:SetLabelObject(tc2)
			tc1:RegisterEffect(e1)
		end
	else
		-- 获取特殊召唤的目标卡片
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标怪兽在自己场上表侧守备表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 装备限制函数，限制装备卡只能装备给指定的怪兽
function c64038662.eqlimit(e,c)
	return c==e:GetLabelObject()
end

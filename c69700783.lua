--ヴァンパイア・デザイア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象才能发动。把持有和那只怪兽的等级不同等级的1只「吸血鬼」怪兽从卡组送去墓地。作为对象的怪兽的等级直到回合结束时变成和送去墓地的怪兽相同。
-- ●以自己墓地1只「吸血鬼」怪兽为对象才能发动。选自己场上1只怪兽送去墓地，作为对象的怪兽特殊召唤。
function c69700783.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●以自己场上1只表侧表示怪兽为对象才能发动。把持有和那只怪兽的等级不同等级的1只「吸血鬼」怪兽从卡组送去墓地。作为对象的怪兽的等级直到回合结束时变成和送去墓地的怪兽相同。●以自己墓地1只「吸血鬼」怪兽为对象才能发动。选自己场上1只怪兽送去墓地，作为对象的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69700783+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c69700783.target)
	e1:SetOperation(c69700783.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且等级大于0的怪兽，且卡组中存在与之等级不同的「吸血鬼」怪兽
function c69700783.tgfilter1(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup()
		-- 检查卡组中是否存在至少1只与该怪兽等级不同的「吸血鬼」怪兽
		and Duel.IsExistingMatchingCard(c69700783.tgfilter2,tp,LOCATION_DECK,0,1,nil,lv)
end
-- 过滤卡组中等级与指定等级不同且能送去墓地的「吸血鬼」怪兽
function c69700783.tgfilter2(c,lv)
	return c:IsSetCard(0x8e) and c:IsLevelAbove(0) and not c:IsLevel(lv) and c:IsAbleToGrave()
end
-- 过滤自己场上能送去墓地且送去墓地后能空出怪兽区域的怪兽
function c69700783.spfilter1(c,tp)
	-- 检查该怪兽是否能送去墓地，且该怪兽离开场上后是否有可用的怪兽区域
	return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤墓地中可以特殊召唤的「吸血鬼」怪兽
function c69700783.spfilter2(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与准备阶段，处理效果分支选择、对象选择及操作信息的注册
function c69700783.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c69700783.tgfilter1(chkc,tp)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69700783.spfilter2(chkc,e,tp)
		end
	end
	-- 检查是否满足发动第一个效果的条件（场上存在符合条件的表侧表示怪兽）
	local b1=Duel.IsExistingTarget(c69700783.tgfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
	-- 检查自己场上是否存在可以送去墓地的怪兽
	local b2=Duel.IsExistingMatchingCard(c69700783.spfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查墓地中是否存在可以特殊召唤的「吸血鬼」怪兽（与场上存在可送墓怪兽共同构成第二个效果的发动条件）
		and Duel.IsExistingTarget(c69700783.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家在“改变等级”和“墓地特殊召唤”两个效果中选择一个发动
		op=Duel.SelectOption(tp,aux.Stringid(69700783,0),aux.Stringid(69700783,1))  --"改变等级/墓地苏生"
	elseif b1 then
		-- 仅满足第一个效果的发动条件，强制选择第一个效果
		op=Duel.SelectOption(tp,aux.Stringid(69700783,0))  --"改变等级"
	else
		-- 仅满足第二个效果的发动条件，强制选择第二个效果并调整选项索引
		op=Duel.SelectOption(tp,aux.Stringid(69700783,1))+1  --"墓地苏生"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只表侧表示怪兽作为效果对象
		Duel.SelectTarget(tp,c69700783.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
		-- 设置效果处理信息：将卡组的1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己墓地1只「吸血鬼」怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c69700783.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置效果处理信息：将自己场上的1张怪兽送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
		-- 设置效果处理信息：将选中的对象怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理函数，根据发动的分支效果分别执行“送墓并改变等级”或“送墓并特殊召唤”
function c69700783.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取作为效果对象的自己场上的怪兽
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只与对象怪兽等级不同的「吸血鬼」怪兽
		local g=Duel.SelectMatchingCard(tp,c69700783.tgfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		-- 将选择的「吸血鬼」怪兽送去墓地，并确认其已成功送去墓地
		if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			local lv=g:GetFirst():GetLevel()
			-- 作为对象的怪兽的等级直到回合结束时变成和送去墓地的怪兽相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		-- 获取作为效果对象的墓地中的「吸血鬼」怪兽
		local tc=Duel.GetFirstTarget()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择自己场上1只怪兽送去墓地
		local tg=Duel.SelectMatchingCard(tp,c69700783.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
		-- 将选中的场上怪兽送去墓地，并确认其已成功送去墓地
		if tg:GetCount()>0 and Duel.SendtoGrave(tg,REASON_EFFECT)~=0 and tg:GetFirst():IsLocation(LOCATION_GRAVE)
			and tc:IsRelateToEffect(e) then
			-- 将作为对象的墓地中的「吸血鬼」怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

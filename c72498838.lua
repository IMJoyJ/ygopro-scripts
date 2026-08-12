--結晶の大賢者サンドリヨン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，可以从以下效果选择1个发动。
-- ●从卡组把1张「大贤者」魔法·陷阱卡加入手卡。
-- ●选除外的1只自己的4星以下的魔法师族怪兽回到墓地。
-- ②：把墓地的这张卡除外，以自己场上1只「大贤者」怪兽为对象才能发动。从自己墓地选1只4星以外的「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。
function c72498838.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，可以从以下效果选择1个发动。●从卡组把1张「大贤者」魔法·陷阱卡加入手卡。●选除外的1只自己的4星以下的魔法师族怪兽回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,72498838)
	e1:SetTarget(c72498838.target)
	e1:SetOperation(c72498838.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只「大贤者」怪兽为对象才能发动。从自己墓地选1只4星以外的「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72498838,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,72498839)
	-- 把墓地的这张卡除外作为效果发动的Cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c72498838.eqtg)
	e3:SetOperation(c72498838.eqop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「大贤者」魔法·陷阱卡且能加入手牌的卡片
function c72498838.thfilter(c)
	return c:IsSetCard(0x150) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤除外状态的表侧表示的4星以下魔法师族怪兽
function c72498838.rtfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER)
end
-- ①效果的发动准备，检测可行效果并由玩家选择其中一个效果发动，设置对应的操作信息
function c72498838.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local sel=0
		-- 检查卡组是否存在可检索的「大贤者」魔陷，若存在则标记选项1可用
		if Duel.IsExistingMatchingCard(c72498838.thfilter,tp,LOCATION_DECK,0,1,nil) then sel=sel+1 end
		-- 检查除外区是否存在可回到墓地的4星以下魔法师族怪兽，若存在则标记选项2可用
		if Duel.IsExistingMatchingCard(c72498838.rtfilter,tp,LOCATION_REMOVED,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		-- 提示玩家选择要发动的效果
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 当两个效果都满足发动条件时，让玩家选择其中一个效果发动
		sel=Duel.SelectOption(tp,aux.Stringid(72498838,0),aux.Stringid(72498838,1))+1  --"从卡组把1张「大贤者」魔法·陷阱卡加入手卡/选除外的1只自己的4星以下的魔法师族怪兽回到墓地"
	elseif sel==1 then
		-- 仅有选项1满足条件时，强制选择并显示选项1
		Duel.SelectOption(tp,aux.Stringid(72498838,0))  --"从卡组把1张「大贤者」魔法·陷阱卡加入手卡"
	else
		-- 仅有选项2满足条件时，强制选择并显示选项2
		Duel.SelectOption(tp,aux.Stringid(72498838,1))  --"选除外的1只自己的4星以下的魔法师族怪兽回到墓地"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置效果处理信息：从卡组将1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 设置效果处理信息：将除外区的1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
	end
end
-- ①效果的效果处理，根据玩家选择的分支执行检索「大贤者」魔陷或将除外的魔法师族怪兽送回墓地
function c72498838.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足条件的「大贤者」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c72498838.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选择的卡片加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从除外区选择1只满足条件的4星以下魔法师族怪兽
		local g=Duel.SelectMatchingCard(tp,c72498838.rtfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			-- 将选择的怪兽送回墓地
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
		end
	end
end
-- 过滤场上表侧表示的「大贤者」怪兽
function c72498838.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 过滤墓地中4星以外的「大贤者」怪兽
function c72498838.eqfilter(c)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and not c:IsLevel(4)
end
-- ②效果的发动准备，检查魔法与陷阱区域是否有空位、场上是否有可选择的「大贤者」怪兽、墓地是否有可装备的4星以外「大贤者」怪兽，并选择场上的怪兽作为效果对象
function c72498838.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c72498838.tgfilter(chkc) end
	-- 在发动时，检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为效果对象的表侧表示「大贤者」怪兽
		and Duel.IsExistingTarget(c72498838.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在除这张卡以外的4星以外的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c72498838.eqfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「大贤者」怪兽作为效果对象
	Duel.SelectTarget(tp,c72498838.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的效果处理，从自己墓地选1只4星以外的「大贤者」怪兽给作为对象的怪兽装备，并设置装备限制
function c72498838.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍在该效果影响下、是否表侧表示，以及魔法与陷阱区域是否有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要作为装备卡的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己墓地选择1只不受「王家长眠之谷」影响的4星以外的「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c72498838.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local ec=g:GetFirst()
		if ec then
			-- 将选择的怪兽作为装备卡装备给对象怪兽，若装备失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 当作装备卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(c72498838.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 设置装备限制，该卡只能装备给作为对象的怪兽
function c72498838.eqlimit(e,c)
	return c==e:GetLabelObject()
end

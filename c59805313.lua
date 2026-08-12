--ヴォルカニック・リムファイア
-- 效果：
-- ①：这张卡被送去墓地的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●墓地的这张卡除外，从卡组把「火山缘发弹」以外的1只「火山」怪兽送去墓地。
-- ●从自己的场上（表侧表示）·墓地把1张「烈焰加农炮」卡除外，从手卡·卡组把1张「烈焰加农炮」永续魔法·永续陷阱卡在自己场上表侧表示放置。
function c59805313.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。●墓地的这张卡除外，从卡组把「火山缘发弹」以外的1只「火山」怪兽送去墓地。●从自己的场上（表侧表示）·墓地把1张「烈焰加农炮」卡除外，从手卡·卡组把1张「烈焰加农炮」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59805313,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c59805313.optg)
	e1:SetOperation(c59805313.opop)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「火山缘发弹」以外的「火山」怪兽
function c59805313.tgfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x32) and not c:IsCode(59805313) and c:IsAbleToGrave()
end
-- 过滤自己场上（表侧表示）或墓地可以除外的「烈焰加农炮」卡
function c59805313.rmfilter(c,tp)
	return c:IsSetCard(0xb9) and c:IsFaceupEx() and c:IsAbleToRemove()
		-- 检查被除外的卡是否在魔陷区，或者自己魔陷区是否有空位（确保有格子放置新卡）
		and (c:IsLocation(LOCATION_SZONE) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- 过滤手卡或卡组中可以放置的「烈焰加农炮」永续魔法·永续陷阱卡
function c59805313.setfilter(c,tp)
	return c:IsSetCard(0xb9) and c:IsType(TYPE_CONTINUOUS)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果①的触发与分支选择处理
function c59805313.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查本回合是否未使用过分支1，且墓地的这张卡可以除外
	local b1=Duel.GetFlagEffect(tp,59805313)==0 and c:IsAbleToRemove()
		-- 检查卡组中是否存在可以送去墓地的「火山」怪兽
		and Duel.IsExistingMatchingCard(c59805313.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 检查本回合是否未使用过分支2
	local b2=Duel.GetFlagEffect(tp,59805314)==0
		-- 检查自己场上或墓地是否存在可以除外的「烈焰加农炮」卡
		and Duel.IsExistingMatchingCard(c59805313.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,tp)
		-- 检查手卡或卡组中是否存在可以放置的「烈焰加农炮」永续魔法·永续陷阱卡
		and Duel.IsExistingMatchingCard(c59805313.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 若两个分支均可发动，则由玩家选择其中一个
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(59805313,1),aux.Stringid(59805313,2))  --"从卡组送去墓地/从手卡·卡组放置"
	-- 若仅能发动分支1，则强制选择分支1
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(59805313,1))  --"从卡组送去墓地"
	-- 若仅能发动分支2，则强制选择分支2
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(59805313,2))+1 end  --"从手卡·卡组放置"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
		-- 注册分支1本回合已使用的标识
		Duel.RegisterFlagEffect(tp,59805313,RESET_PHASE+PHASE_END,0,1)
		-- 设置操作信息：除外墓地的这张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
		-- 设置操作信息：从卡组将1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_REMOVE)
		-- 注册分支2本回合已使用的标识
		Duel.RegisterFlagEffect(tp,59805314,RESET_PHASE+PHASE_END,0,1)
		-- 设置操作信息：除外场上或墓地的1张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
-- 效果①的分支效果处理
function c59805313.opop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		-- 检查此卡是否仍在墓地，并将其除外
		if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 玩家从卡组选择1张满足条件的「火山」怪兽
			local g1=Duel.SelectMatchingCard(tp,c59805313.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g1>0 then
				-- 将选中的怪兽送去墓地
				Duel.SendtoGrave(g1,REASON_EFFECT)
			end
		end
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家从场上或墓地选择1张「烈焰加农炮」卡（受王家长眠之谷影响）
		local rmg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c59805313.rmfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,tp)
		-- 若成功除外选中的「烈焰加农炮」卡
		if #rmg>0 and Duel.Remove(rmg,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 提示玩家选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 玩家从手卡或卡组选择1张「烈焰加农炮」永续魔法·永续陷阱卡
			local g2=Duel.SelectMatchingCard(tp,c59805313.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
			if #g2>0 then
				-- 将选中的卡在自己魔陷区表侧表示放置
				Duel.MoveToField(g2:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
		end
	end
end

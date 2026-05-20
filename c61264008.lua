--土地ころがし
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或者对方的场地区域1张表侧表示的卡为对象才能发动。那张卡除外。那之后，这个效果除外的卡在从被除外的玩家来看的对方的场地区域表侧表示放置。那之后，可以从被放置的玩家的墓地选原本卡名和放置的卡不同的1张场地魔法卡在被这个效果把卡除外的玩家的场地区域表侧表示放置。
function c61264008.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己或者对方的场地区域1张表侧表示的卡为对象才能发动。那张卡除外。那之后，这个效果除外的卡在从被除外的玩家来看的对方的场地区域表侧表示放置。那之后，可以从被放置的玩家的墓地选原本卡名和放置的卡不同的1张场地魔法卡在被这个效果把卡除外的玩家的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,61264008+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61264008.target)
	e1:SetOperation(c61264008.activate)
	c:RegisterEffect(e1)
end
-- 过滤场地区域表侧表示且可以除外的卡片
function c61264008.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 过滤原本卡名与指定卡片不同的场地魔法卡
function c61264008.filter2(c,code)
	return c:IsType(TYPE_FIELD) and not c:IsCode(code)
end
-- 效果发动时的对象选择与操作信息设置
function c61264008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) and c61264008.filter(chkc) end
	-- 检查双方场地区域是否存在可作为对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c61264008.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方场地区域1张表侧表示的卡片作为效果对象
	local g=Duel.SelectTarget(tp,c61264008.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	-- 设置效果处理信息为除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理的核心逻辑，包含除外、移动位置以及后续的从墓地放置场地魔法
function c61264008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ttp=tc:GetControler()
		-- 将对象卡片表侧表示除外，并判断是否除外成功
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 获取本次操作中实际被除外的卡片组
			local g=Duel.GetOperatedGroup()
			local tc2=g:GetFirst()
			local code=tc2:GetOriginalCode()
			-- 将除外的卡在被除外玩家的对手的场地区域表侧表示放置，并判断是否成功
			if Duel.MoveToField(tc2,1-ttp,1-ttp,LOCATION_FZONE,POS_FACEUP,true)~=0
				-- 检查被放置卡片的玩家（被除外玩家的对手）的墓地中是否存在原本卡名与放置卡片不同的场地魔法卡
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c61264008.filter2),1-ttp,LOCATION_GRAVE,0,1,nil,code)
				-- 询问发动效果的玩家是否选择从墓地放置场地魔法卡
				and Duel.SelectYesNo(tp,aux.Stringid(61264008,0)) then  --"是否从墓地选场地魔法卡上场？"
				-- 中断当前效果处理，使后续的放置处理不与前面的放置处理同时进行
				Duel.BreakEffect()
				-- 玩家从被放置卡片玩家的墓地中选择1张原本卡名与放置卡片不同的场地魔法卡
				local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61264008.filter2),1-ttp,LOCATION_GRAVE,0,1,1,nil,code)
				if #rg>0 then
					-- 将选中的场地魔法卡在被除外玩家的场地区域表侧表示放置
					Duel.MoveToField(rg:GetFirst(),tp,ttp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end

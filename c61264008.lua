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
-- 过滤函数：表侧表示且可以被除外的卡（用于选择场地区域的除外对象）
function c61264008.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 过滤函数：场地魔法卡且原本卡名与指定卡不同的卡（用于从墓地选场地魔法卡）
function c61264008.filter2(c,code)
	return c:IsType(TYPE_FIELD) and not c:IsCode(code)
end
-- 取对象处理：确认双方场地区域存在可除外的表侧表示卡，选择其中1张作为对象，并设置除外操作信息
function c61264008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) and c61264008.filter(chkc) end
	-- 发动条件检测：自己或对方的场地区域存在至少1张可以成为对象的表侧表示且可除外的卡
	if chk==0 then return Duel.IsExistingTarget(c61264008.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己或对方的场地区域选择1张表侧表示且可除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,c61264008.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	-- 设置操作信息：这个效果确定要把作为对象的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：把对象的场地区域的卡除外，放置到对方场地区域，之后可从墓地选1张不同卡名的场地魔法卡放置到把卡除外的玩家的场地区域
function c61264008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ttp=tc:GetControler()
		-- 将对象卡以表侧表示除外，成功除外才继续处理
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 取得刚才除外操作实际除外的卡片组
			local g=Duel.GetOperatedGroup()
			local tc2=g:GetFirst()
			local code=tc2:GetOriginalCode()
			-- 把被除外的卡在从被除外的玩家来看的对方的场地区域表侧表示放置，成功才继续处理
			if Duel.MoveToField(tc2,1-ttp,1-ttp,LOCATION_FZONE,POS_FACEUP,true)
				-- 检查被放置的玩家的墓地是否存在原本卡名和放置的卡不同且不受王家长眠之谷影响的场地魔法卡
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c61264008.filter2),1-ttp,LOCATION_GRAVE,0,1,nil,code)
				-- 询问发动玩家是否要从墓地选场地魔法卡上场
				and Duel.SelectYesNo(tp,aux.Stringid(61264008,0)) then  --"是否从墓地选场地魔法卡上场？"
				-- 中断当前效果处理，使之后的放置处理与前面的除外、放置不同时进行
				Duel.BreakEffect()
				-- 让发动玩家从被放置的玩家的墓地选1张原本卡名和放置的卡不同的场地魔法卡
				local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61264008.filter2),1-ttp,LOCATION_GRAVE,0,1,1,nil,code)
				if #rg>0 then
					-- 把选择的场地魔法卡在被这个效果把卡除外的玩家的场地区域表侧表示放置
					Duel.MoveToField(rg:GetFirst(),tp,ttp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end

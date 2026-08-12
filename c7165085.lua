--おとり人形
-- 效果：
-- 选择魔法与陷阱卡区域盖放的1张卡发动。选择的卡翻开确认，那张卡是陷阱卡的场合，强制发动。发动时机不正确的场合，那个效果无效并破坏。那张卡是陷阱卡以外的场合，回到原状。这张卡发动后，不送去墓地回到卡组。
function c7165085.initial_effect(c)
	-- 选择魔法与陷阱卡区域盖放的1张卡发动。选择的卡翻开确认，那张卡是陷阱卡的场合，强制发动。发动时机不正确的场合，那个效果无效并破坏。那张卡是陷阱卡以外的场合，回到原状。这张卡发动后，不送去墓地回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7165085.target)
	e1:SetOperation(c7165085.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：魔法与陷阱卡区域盖放的卡（不含场地区）
function c7165085.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 效果发动的对象选择与合法性检测
function c7165085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c7165085.filter(chkc) end
	-- 检查魔法与陷阱卡区域是否存在可以作为对象的盖放卡片
	if chk==0 then return Duel.IsExistingTarget(c7165085.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 给发动玩家发送提示信息：请选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择魔法与陷阱卡区域盖放的1张卡作为效果的对象
	Duel.SelectTarget(tp,c7165085.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
end
-- 效果处理的核心逻辑：确认卡片、强制发动陷阱卡或使其无效破坏、不送去墓地回到卡组
function c7165085.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then
		if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 若对象卡不合法，则将这张卡（诱饵人偶）洗回卡组
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
		end
		return
	end
	-- 将选择的卡翻开给双方确认
	Duel.ConfirmCards(tp,tc)
	if tc:IsType(TYPE_TRAP) then
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		if not te then
			-- 若该卡是陷阱卡但没有可发动的效果，则将其表侧表示放置在场上
			Duel.ChangePosition(tc,POS_FACEUP)
			-- 尝试以效果破坏该卡，若破坏失败则执行后续处理
			if Duel.Destroy(tc,REASON_EFFECT)==0 then
				-- 若因效果免疫等原因无法被效果破坏，则根据规则送去墓地
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		else
			local condition=te:GetCondition()
			local cost=te:GetCost()
			local target=te:GetTarget()
			local operation=te:GetOperation()
			if te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
				and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
				and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
				and (not target or target(te,tep,eg,ep,ev,re,r,rp,0)) then
				-- 清除当前连锁的对象卡片信息，防止干扰强制发动的效果
				Duel.ClearTargetCard()
				e:SetProperty(te:GetProperty())
				-- 向双方玩家展示强制发动的陷阱卡
				Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
				-- 将强制发动的陷阱卡翻开变为表侧表示
				Duel.ChangePosition(tc,POS_FACEUP)
				if tc:GetType()==TYPE_TRAP then
					tc:CancelToGrave(false)
				end
				tc:CreateEffectRelation(te)
				if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
				if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
				-- 获取强制发动的陷阱卡所选择的对象卡片组
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				local tg=g:GetFirst()
				while tg do
					tg:CreateEffectRelation(te)
					tg=g:GetNext()
				end
				if operation then operation(te,tep,eg,ep,ev,re,r,rp) end
				tc:ReleaseEffectRelation(te)
				tg=g:GetFirst()
				while tg do
					tg:ReleaseEffectRelation(te)
					tg=g:GetNext()
				end
			else
				-- 若发动时机不正确，尝试以效果破坏该卡
				if Duel.Destroy(tc,REASON_EFFECT)==0 then
					-- 若因效果免疫等原因无法被效果破坏，则根据规则送去墓地
					Duel.SendtoGrave(tc,REASON_RULE)
				end
			end
		end
	end
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 效果处理完毕后，将这张卡（诱饵人偶）洗回卡组
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end

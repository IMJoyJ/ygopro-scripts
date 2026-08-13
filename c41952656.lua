--イマイルカ
-- 效果：
-- 场上的这张卡被对方破坏送去墓地时，自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，从自己卡组抽1张卡。
function c41952656.initial_effect(c)
	-- 场上的这张卡被对方破坏送去墓地时，自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41952656,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c41952656.drcon)
	e1:SetTarget(c41952656.drtg)
	e1:SetOperation(c41952656.drop)
	c:RegisterEffect(e1)
end
-- 判定诱发条件：自身因破坏被送去墓地、非规则破坏、破坏来源控制者为对方、自身之前控制者为效果发动方，即满足‘场上的这张卡被对方破坏送去墓地时’。
function c41952656.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and not c:IsReason(REASON_RULE) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 效果发动时的合法检测：该效果不取对象且触发条件已在Condition中判断，Target阶段直接返回 true 允许发动，并登记本次连锁的操作信息。
function c41952656.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记‘从卡组送墓’的操作信息：未指定具体对象，预计由己方卡组送墓1张卡，供其他连锁检测（如星尘龙等）参考。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果处理函数：将己方卡组最上面1张卡送去墓地，然后检查送墓的卡是否水属性，若是则抽1张卡，完整实现卡面效果。
function c41952656.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将己方卡组最上方1张卡送去墓地；若实际送墓成功（卡组非空且未被无效）则返回 1，继续后续处理。
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)==1 then
		-- 获取刚才 DiscardDeck 实际操作的卡组（即被送去墓地的那张卡），用于检查其属性。
		local g=Duel.GetOperatedGroup()
		if g:GetFirst():IsAttribute(ATTRIBUTE_WATER) then
			-- 由于送墓的卡满足水属性条件，以效果原因从自己卡组抽1张卡，对应‘从自己卡组抽1张卡’。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

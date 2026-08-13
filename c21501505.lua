--暗遷士 カンゴルゴーム
-- 效果：
-- 4星怪兽×2
-- ①：只以场上的卡1张为对象的其他的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除，以场上1张作为正确对象的别的卡为对象才能发动。那个效果的对象转移为作为正确对象的那张卡。
function c21501505.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只4星怪兽叠放进行XYZ召唤（不限制素材种族/属性）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：只以场上的卡1张为对象的其他的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除，以场上1张作为正确对象的别的卡为对象才能发动。那个效果的对象转移为作为正确对象的那张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21501505,0))  --"对象转移"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21501505.condition)
	e1:SetCost(c21501505.cost)
	e1:SetTarget(c21501505.target)
	e1:SetOperation(c21501505.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：确认要连锁的效果不是自身、且是取对象效果，且该效果当前只有1个对象卡并且该对象卡在场上；满足则将该对象卡保存到效果标签中供后续筛选使用。
function c21501505.condition(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁序号ev对应的效果的对象卡片组（即对方发动的那个取对象效果当前指定的对象卡）。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField()
end
-- 发动代价：检查并移除这张卡自身1个超量素材。
function c21501505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选函数：判断场上的某张卡c是否能成为连锁序号ct所对应效果的合法对象，用于选出“作为正确对象的别的卡”。
function c21501505.filter(c,ct)
	-- 调用Duel.CheckChainTarget查询该卡能否成为连锁ct的效果的正确对象，返回真/假。
	return Duel.CheckChainTarget(ct,c)
end
-- 效果发动时的处理：从场上选择1张除原对象外、能够成为对应连锁效果正确对象的卡作为效果对象；同时用标志效果记录当前连锁信息，确保在相同连锁上多次发动时也能正确对应各自需要转移的效果。
function c21501505.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=ev
	-- 获取玩家0（场地效果）上已登记的暗迁士标志效果的标签值，用于判断是否已有本卡效果在此连锁链上发动过并存储了信息。
	local label=Duel.GetFlagEffectLabel(0,21501505)
	if label then
		if ev==bit.rshift(label,16) then ct=bit.band(label,0xffff) end
	end
	if chkc then return chkc:IsOnField() and c21501505.filter(chkc,ct) end
	-- 发动合法性检查：确认场上存在至少1张除原对象外能作为对应连锁效果对象的卡，以保证可以选取目标。
	if chk==0 then return Duel.IsExistingTarget(c21501505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabelObject(),ct) end
	-- 向当前玩家显示选择目标的提示信息（请选择效果的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从场上选择1张满足条件的卡作为本效果的对象，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c21501505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetLabelObject(),ct)
	local val=ct+bit.lshift(ev+1,16)
	if label then
		-- 更新已有的暗迁士标志效果标签为当前连锁信息（高16位记录原连锁+1，低16位记录当前连锁编号），以便后续操作时关联正确的连锁。
		Duel.SetFlagEffectLabel(0,21501505,val)
	else
		-- 若不存在暗迁士标志，则注册一个连锁结束时重置的标志效果，并设置其标签为当前连锁信息（同上），用于在同一连锁上记录多个发动情况。
		Duel.RegisterFlagEffect(0,21501505,RESET_CHAIN,0,1,val)
	end
end
-- 效果处理：将选定的目标卡转移为对应连锁效果的新对象，完成对象转移。
function c21501505.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的目标卡（即要成为新对象的“别的卡”）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将连锁ev对应效果的对象变更为tc这张卡，实现“那个效果的对象转移为作为正确对象的那张卡”。
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end

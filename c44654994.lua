--アルトメギア・インパスト－奪還－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有「神艺」怪兽存在的场合，这张卡在盖放的回合也能发动。
-- ①：对方把怪兽的效果发动时才能发动。自己场上1只融合怪兽直到结束阶段除外，那个发动无效并破坏。那之后，自己场上的怪兽的种族是3种类以上的场合，可以让对方场上的魔法·陷阱卡全部回到手卡。
local s,id,o=GetID()
-- 为「神艺学的厚涂-夺还-」注册两个效果：e1为①的发动效果（对方怪兽效果发动时发动，除外己方融合怪兽并无效破坏，之后可弹对方魔陷）；e2为盖放回合可发动的效果（自己场上有「神艺」怪兽时适用）。
function s.initial_effect(c)
	-- ①：对方把怪兽的效果发动时才能发动。自己场上1只融合怪兽直到结束阶段除外，那个发动无效并破坏。那之后，自己场上的怪兽的种族是3种类以上的场合，可以让对方场上的魔法·陷阱卡全部回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 自己场上有「神艺」怪兽存在的场合，这张卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"适用「神艺学的厚涂-夺还-」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于检查场上是否存在表侧表示且卡名含有「神艺」的怪兽。
function s.acfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cd)
end
-- e2的发动条件：自己场上有表侧表示「神艺」怪兽存在时，这张卡在盖放回合也能发动。
function s.actcon(e)
	-- 检查以该卡控制者视角，自己主要怪兽区是否存在至少1只表侧表示的「神艺」怪兽。
	return Duel.IsExistingMatchingCard(s.acfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- e1的发动条件：对方把怪兽的效果发动时才能发动，且该连锁发动的效果可以被无效。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发动的控制者是对方（rp==1-tp），且发动的是怪兽效果，且该发动能够被无效。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义选择自己场上融合怪兽的过滤条件：表侧表示且为融合怪兽，并能被除外。
function s.rmsfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
		and c:IsAbleToRemove()
end
-- 效果发动时，确认自己场上存在符合条件的融合怪兽才能发动；并设置处理信息：除外1只融合怪兽、无效对方怪兽效果发动；若该怪兽可破坏且仍与效果关联，则也设置破坏信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：自己场上是否存在至少1只表侧表示的融合怪兽且可被除外。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmsfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有符合条件的融合怪兽组，用于设置操作信息。
	local g=Duel.GetMatchingGroup(s.rmsfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息，本次效果将除外1只自己场上的融合怪兽（数量固定为1）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息，本次效果将无效对方发动的怪兽效果（以eg作为对象）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，如果对方发动的那只怪兽可被破坏且仍与该效果关联，则本次效果将破坏它。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义过滤函数，用于选择对方场上的魔法·陷阱卡并将其回到手牌。
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理：选择除外自己场上1只融合怪兽直到结束阶段，若成功则无效对方怪兽效果的发动并破坏；那之后，若自己场上的怪兽种族为3种以上，则可以选择让对方场上的魔法·陷阱卡全部回到手牌。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡片（显示“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只符合条件的融合怪兽（表侧表示且可除外）。
	local dg=Duel.SelectMatchingCard(tp,s.rmsfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=dg:GetFirst()
	if tc then
		-- 向双方展示所选卡片，并记录其成为对象。
		Duel.HintSelection(dg)
		-- 将选中的融合怪兽以效果原因暂时除外；若成功则继续后续处理。
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"直到结束阶段除外"
			-- 自己场上1只融合怪兽直到结束阶段除外，那个发动无效并破坏。那之后，自己场上的怪兽的种族是3种类以上的场合，可以让对方场上的魔法·陷阱卡全部回到手卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 将在结束阶段把除外怪兽返回场上的持续效果注册到当前玩家场上。
			Duel.RegisterEffect(e1,tp)
			-- 尝试无效对方怪兽效果的发动（ev为被无效的连锁）。
			if Duel.NegateActivation(ev)
				-- 若无效成功，且对方那只怪兽仍与连锁关联，则将其破坏；破坏成功后才进入后续回手牌处理。
				and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
				-- 获取自己场上所有表侧表示怪兽，用于检查种族种类数。
				local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				-- 获取对方场上所有可回到手牌的魔法·陷阱卡。
				local rg=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_ONFIELD,nil)
				-- 若对方场上有可回手的魔陷、自己场上怪兽的种族种类大于2，且玩家选择“是”，则执行回手牌处理。
				if rg:GetCount()>0 and g:GetClassCount(Card.GetRace)>2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否让魔法·陷阱卡回到手卡？"
					-- 中断当前效果，使后续回手牌处理作为不同时处理（错开时点）。
					Duel.BreakEffect()
					-- 将对方场上的魔法·陷阱卡全部弹回持有者手牌。
					Duel.SendtoHand(rg,nil,REASON_EFFECT)
				end
			end
		end
	end
end
-- 返回效果的条件：被除外的怪兽仍带有该卡的效果标记，即仍未在结束阶段前离场或重置。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 结束阶段处理：将暂时除外的融合怪兽返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的融合怪兽以离场前的表示形式返回其原本的控制者场上。
	Duel.ReturnToField(e:GetLabelObject())
end

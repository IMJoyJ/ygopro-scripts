--アルトメギア・インパスト－奪還－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有「神艺」怪兽存在的场合，这张卡在盖放的回合也能发动。
-- ①：对方把怪兽的效果发动时才能发动。自己场上1只融合怪兽直到结束阶段除外，那个发动无效并破坏。那之后，自己场上的怪兽的种族是3种类以上的场合，可以让对方场上的魔法·陷阱卡全部回到手卡。
local s,id,o=GetID()
-- 注册效果：发动时，使对方怪兽效果无效并破坏，同时除外自己场上1只融合怪兽，若自己场上怪兽种族种类≥3则可让对方魔法·陷阱卡回手
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
-- 过滤函数：检查场上是否有表侧表示的「神艺」怪兽
function s.acfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cd)
end
-- 效果发动条件：检查自己场上是否存在「神艺」怪兽
function s.actcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「神艺」怪兽
	return Duel.IsExistingMatchingCard(s.acfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 连锁发动条件：对方怪兽效果发动时
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽效果发动时且该连锁可被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：检查场上是否有表侧表示的融合怪兽且可除外
function s.rmsfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
		and c:IsAbleToRemove()
end
-- 效果目标设定：选择1只自己场上的融合怪兽除外，并设置连锁无效和破坏效果的目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：自己场上是否存在至少1只融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmsfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取满足条件的融合怪兽组
	local g=Duel.GetMatchingGroup(s.rmsfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤函数：检查对方场上的魔法·陷阱卡
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理：选择1只自己场上的融合怪兽除外，使对方怪兽效果无效并破坏，若满足条件则让对方魔法·陷阱卡回手
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只自己场上的融合怪兽除外
	local dg=Duel.SelectMatchingCard(tp,s.rmsfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=dg:GetFirst()
	if tc then
		-- 显示选中的融合怪兽被除外的动画
		Duel.HintSelection(dg)
		-- 将选中的融合怪兽以临时除外形式除外
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"直到结束阶段除外"
			-- 注册结束阶段返回场上的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册效果到玩家环境
			Duel.RegisterEffect(e1,tp)
			-- 使连锁发动无效
			if Duel.NegateActivation(ev)
				-- 确认连锁发动的卡存在且可破坏
				and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
				-- 获取自己场上所有表侧表示的怪兽
				local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				-- 获取对方场上的魔法·陷阱卡
				local rg=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_ONFIELD,nil)
				-- 判断是否满足让对方魔法·陷阱卡回手的条件：对方魔法·陷阱卡存在且自己场上怪兽种族种类≥3
				if rg:GetCount()>0 and g:GetClassCount(Card.GetRace)>2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否让魔法·陷阱卡回到手卡？"
					-- 中断当前效果处理
					Duel.BreakEffect()
					-- 将对方魔法·陷阱卡送回手牌
					Duel.SendtoHand(rg,nil,REASON_EFFECT)
				end
			end
		end
	end
end
-- 返回效果：判断融合怪兽是否仍处于除外状态
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 效果处理：将融合怪兽返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将融合怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end

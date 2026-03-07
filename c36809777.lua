--獣烈な争い
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方玩家在自身场上有相同种类（仪式·融合·同调·超量·连接）的怪兽2只以上存在的场合，直到那种类的怪兽变成1只为止必须送去墓地。那之后，送去墓地的玩家从卡组抽出自身场上的怪兽种类（仪式·融合·同调·超量·连接）的数量。
function c36809777.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36809777+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c36809777.target)
	e1:SetOperation(c36809777.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查双方玩家场上有无相同种类怪兽2只以上存在
function c36809777.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for i,p in ipairs({tp,1-tp}) do
			-- 效果作用：获取指定玩家场上正面表示的怪兽组
			local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
			for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}) do
				local rg=g:Filter(Card.IsType,nil,type)
				local rc=rg:GetCount()
				if rc>1 then
					return true
				end
			end
		end
		return false
	end
	-- 效果作用：设置连锁操作信息为送去墓地效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
-- 效果原文内容：①：双方玩家在自身场上有相同种类（仪式·融合·同调·超量·连接）的怪兽2只以上存在的场合，直到那种类的怪兽变成1只为止必须送去墓地。那之后，送去墓地的玩家从卡组抽出自身场上的怪兽种类（仪式·融合·同调·超量·连接）的数量。
function c36809777.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前回合玩家
	tp=Duel.GetTurnPlayer()
	local res={}
	for i,p in ipairs({tp,1-tp}) do
		local sg=Group.CreateGroup()
		-- 效果作用：获取指定玩家场上正面表示的怪兽组
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}) do
			local rg=g:Filter(Card.IsType,nil,type)
			local rc=rg:GetCount()
			if rc>1 then
				-- 效果作用：提示玩家选择要送去墓地的卡
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local dg=rg:Select(p,rc-1,rc-1,nil)
				sg:Merge(dg)
			end
		end
		if sg:GetCount()>0 then
			res[p]=true
			-- 效果作用：将指定卡送去墓地，原因设为规则
			Duel.SendtoGrave(sg,REASON_RULE)
		end
	end
	if res[0] or res[1] then
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
	end
	for i,p in ipairs({tp,1-tp}) do
		if res[p] then
			local ct=0
			-- 效果作用：获取指定玩家场上正面表示的怪兽组
			local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
			for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}) do
				if g:IsExists(Card.IsType,1,nil,type) then ct=ct+1 end
			end
			-- 效果作用：让玩家从卡组抽指定数量的卡，原因设为效果
			Duel.Draw(p,ct,REASON_EFFECT)
		end
	end
end

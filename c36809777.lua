--獣烈な争い
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方玩家在自身场上有相同种类（仪式·融合·同调·超量·连接）的怪兽2只以上存在的场合，直到那种类的怪兽变成1只为止必须送去墓地。那之后，送去墓地的玩家从卡组抽出自身场上的怪兽种类（仪式·融合·同调·超量·连接）的数量。
function c36809777.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：双方玩家在自身场上有相同种类（仪式·融合·同调·超量·连接）的怪兽2只以上存在的场合，直到那种类的怪兽变成1只为止必须送去墓地。那之后，送去墓地的玩家从卡组抽出自身场上的怪兽种类（仪式·融合·同调·超量·连接）的数量。
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
-- 发动条件判定：检查双方玩家场上是否存在表侧表示且包含任意种类（仪式/融合/同调/超量/连接）怪兽2只以上的情况，满足则可发动；发动时向系统登记送去墓地的操作信息。
function c36809777.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for i,p in ipairs({tp,1-tp}) do
			-- 取得玩家p场上的全部表侧表示怪兽，作为后续筛选的基础集合。
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
	-- 设置操作信息，宣告本效果可能进行1张卡的送去墓地处理，用于相关效果（如星尘龙等）的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
-- 效果处理：从回合玩家开始，依次处理双方玩家；对每种怪兽种类，若该玩家场上有复数只同种类怪兽，则选择并送去墓地直到该种类剩1只；有玩家送墓后，中断连锁分段处理，再让送墓的玩家按自身场上剩余怪兽种类数抽卡。
function c36809777.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家，效果中双方玩家按回合玩家先行的顺序进行处理。
	tp=Duel.GetTurnPlayer()
	local res={}
	for i,p in ipairs({tp,1-tp}) do
		local sg=Group.CreateGroup()
		-- 取得当前处理玩家p场上的全部表侧表示怪兽，用于筛选各种类数量。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}) do
			local rg=g:Filter(Card.IsType,nil,type)
			local rc=rg:GetCount()
			if rc>1 then
				-- 向玩家p弹出“请选择要送去墓地的卡”的选择提示。
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local dg=rg:Select(p,rc-1,rc-1,nil)
				sg:Merge(dg)
			end
		end
		if sg:GetCount()>0 then
			res[p]=true
			-- 将选出的怪兽以规则理由送去墓地（这是效果强制的送墓，不受“送去墓地”效果无效等影响）。
			Duel.SendtoGrave(sg,REASON_RULE)
		end
	end
	if res[0] or res[1] then
		-- 中断当前效果链，使此后的抽卡处理与前面的送墓处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
	end
	for i,p in ipairs({tp,1-tp}) do
		if res[p] then
			local ct=0
			-- 抽卡前再次取得该玩家场上的表侧表示怪兽，用于计算当前场上存在的怪兽种类数。
			local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
			for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}) do
				if g:IsExists(Card.IsType,1,nil,type) then ct=ct+1 end
			end
			-- 让该玩家抽取其场上表侧表示怪兽的种类数量（存在仪式则算1，融合算1，依此类推）的卡片。
			Duel.Draw(p,ct,REASON_EFFECT)
		end
	end
end

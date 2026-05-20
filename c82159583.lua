--道化の一座 ホワイトフェイス
-- 效果：
-- 这张卡可以把1只仪式·融合·同调·超量·灵摆·连接怪兽解放表侧表示上级召唤。
-- ①：这张卡上级召唤的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己抽出因为这张卡的上级召唤而解放的怪兽的数量。
-- ●把为这张卡的上级召唤而解放的怪兽数量的对方场上的表侧表示卡的效果无效。
-- ②：1回合1次，对方主要阶段才能发动。进行1只怪兽的上级召唤。
local s,id,o=GetID()
-- 初始化效果：注册特殊上级召唤规则、召唤成功时选择发动的诱发效果、以及对方主要阶段进行上级召唤的即时诱发效果。
function s.initial_effect(c)
	-- 这张卡可以把1只仪式·融合·同调·超量·灵摆·连接怪兽解放表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"用1只怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：这张卡上级召唤的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选择效果"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方主要阶段才能发动。进行1只怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.sumcon)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end
-- 过滤满足特殊上级召唤解放条件的怪兽：自己场上的或对方场上表侧表示的仪式、融合、同调、超量、灵摆、连接怪兽。
function s.otfilter(c,tp)
	return c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判定是否满足特殊上级召唤的条件：自身等级在7星以上、需要1个祭品、且场上存在满足条件的解放怪兽。
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有满足解放条件的怪兽组。
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查自身等级是否在7星以上、所需祭品数是否为1、以及场上是否存在可用于解放的怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行特殊上级召唤的解放处理：选择1只满足条件的怪兽解放，并将其设为召唤素材。
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有满足解放条件的怪兽组。
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只满足解放条件的怪兽作为祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的怪兽作为上级召唤的素材解放。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判定发动条件：这张卡必须是上级召唤成功的场合。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果①的发动准备：获取解放的怪兽数量，根据是否满足抽卡或无效效果的条件以及同名卡回合限制，让玩家选择其中一个效果发动，并注册对应的回合限制标识。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetMaterialCount()
	if chk==0 and ct==0 then return false end
	-- 判定是否满足抽卡效果的条件：玩家可以从卡组抽对应数量的卡。
	local b1=Duel.IsPlayerCanDraw(tp,ct)
		-- 并且在进行发动确认时，该抽卡效果在本回合尚未被选择过。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 判定是否满足无效效果的条件：对方场上存在至少对应数量的表侧表示卡片。
	local b2=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,nil)
		-- 并且在进行发动确认时，该无效效果在本回合尚未被选择过。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可发动的效果中选择其中一个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"抽卡"
			{b2,aux.Stringid(id,4),2})  --"无效"
	end
	e:SetLabel(op,ct)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DRAW)
			-- 注册抽卡效果的回合选择标识，确保本回合不能再次选择此效果。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置效果处理信息：动作为抽卡，数量为解放的怪兽数量。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DISABLE)
			-- 注册无效效果的回合选择标识，确保本回合不能再次选择此效果。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取对方场上所有的表侧表示卡片。
		local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
		-- 设置效果处理信息：动作为无效效果，目标为对方场上的卡片。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- 效果①的效果处理：根据玩家的选择，执行抽卡处理，或者选择对方场上对应数量的表侧表示卡片并将其效果永久无效。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op,ct=e:GetLabel()
	if op==1 then
		-- 玩家因效果抽解放怪兽数量的卡。
		Duel.Draw(tp,ct,REASON_EFFECT)
	elseif op==2 then
		-- 检查对方场上是否存在足够数量的表侧表示卡片，若不足则不处理。
		if not Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,nil) then return end
		-- 提示玩家选择要无效的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择与解放怪兽数量相同的对方场上的表侧表示卡片。
		local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		if g:GetCount()>0 then
			-- 显式指示被选中的卡片。
			Duel.HintSelection(g)
			-- 遍历所有被选中的卡片。
			for tc in aux.Next(g) do
				-- 无效与目标卡片相关的连锁。
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- ●把为这张卡的上级召唤而解放的怪兽数量的对方场上的表侧表示卡的效果无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- ●把为这张卡的上级召唤而解放的怪兽数量的对方场上的表侧表示卡的效果无效。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					-- ●把为这张卡的上级召唤而解放的怪兽数量的对方场上的表侧表示卡的效果无效。
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
				end
			end
		end
	end
end
-- 判定发动条件：必须在对方回合的主要阶段。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合且处于主要阶段。
	return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
end
-- 过滤手牌中可以进行通常召唤（或盖放）的怪兽。
function s.sumfilter(c)
	return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
end
-- 效果②的发动准备：检查手牌中是否存在可以召唤的怪兽，并设置召唤的操作信息。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否可以发动：检查手牌中是否存在至少1只可以进行通常召唤或盖放的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理信息：动作为通常召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：从手牌选择1只怪兽，让玩家选择其表示形式（表侧攻击表示召唤或里侧守备表示盖放），并执行通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌选择1只可以进行通常召唤或盖放的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 若该怪兽既可召唤也可盖放，则让玩家选择表示形式；若只能召唤，则默认选择表侧表示。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 执行通常召唤（表侧表示）。
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 执行通常召唤的Set（里侧守备表示盖放）。
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end

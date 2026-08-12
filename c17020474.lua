--鬼神 朱沙之王
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，从自己墓地把陷阱卡任意数量除外才能发动。那个数量的场上的卡除外。
-- ②：自己·对方的结束阶段，以自己的墓地·除外状态的最多2张「艮神鬼」怪兽·陷阱卡为对象才能发动。那些卡各加入手卡或在自己场上盖放。以2张卡为对象发动的场合，再让这张卡回到额外卡组。
local s,id,o=GetID()
-- 初始化效果：为这张卡设置同调召唤手续与苏生限制，并注册①效果（除外）和②效果（回收·盖放）
function s.initial_effect(c)
	-- 设置同调召唤素材：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，从自己墓地把陷阱卡任意数量除外才能发动。那个数量的场上的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，以自己的墓地·除外状态的最多2张「艮神鬼」怪兽·陷阱卡为对象才能发动。那些卡各加入手卡或在自己场上盖放。以2张卡为对象发动的场合，再让这张卡回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_SSET+CATEGORY_MSET+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 发动条件：这张卡是同调召唤的场合才能发动
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：可以除外的陷阱卡（用于从自己墓地选择除外的卡）
function s.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价：从自己墓地选择任意数量的陷阱卡除外，并将除外的数量记入标签
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方场上可以除外的卡的数量，作为最多可选择的除外数量
	local ct=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 发动判定：自己墓地存在至少1张可以除外的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张至ct张可以除外的陷阱卡
	local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 把选择的陷阱卡表侧表示除外，作为效果发动的代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- 对象判定：代价已支付且场上存在可以除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 双方场上存在至少1张可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得双方场上所有可以除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将场上的卡除外，数量为代价除外的陷阱卡数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,e:GetLabel(),0,0)
end
-- ①效果处理：从场上选择与除外数量相同数量的卡并除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 若场上可以除外的卡数量不足，则不进行除外处理
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)<ct then return end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方场上选择ct张可以除外的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	if #sg>0 then
		-- 显示所选卡的动画，并记录这些卡被选择
		Duel.HintSelection(sg)
		-- 把选择的场上的卡表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 对象过滤：自己墓地·除外状态的表侧表示的「艮神鬼」怪兽·陷阱卡，且可以加入手卡或在自己场上盖放
function s.tgfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER+TYPE_TRAP)
		and (c:IsAbleToHand() or s.setfilter(c,e,tp))
end
-- 盖放过滤：可以里侧表示特殊召唤的怪兽（且主要怪兽区域有空位），或者可以盖放的陷阱卡
function s.setfilter(c,e,tp)
	-- 该卡为怪兽、可以里侧守备表示特殊召唤，并且自己的主要怪兽区域有空位
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		or c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 过滤：墓地中的怪兽卡（用于判定是否需要墓地特殊召唤的效果分类）
function s.cspfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE)
end
-- ②效果对象选择：从自己墓地·除外状态以最多2张满足条件的卡为对象；以2张为对象时设置这张卡回到额外卡组的操作信息，并根据所选卡的种类设置效果分类
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tgfilter(chkc,e,tp) end
	-- 发动判定：存在可以成为对象的「艮神鬼」怪兽·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	local ct=1
	if c:IsAbleToExtra() then ct=2 end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己墓地·除外状态选择1至ct张满足条件的卡作为对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil,e,tp)
	if g:GetCount()==2 then
		e:SetLabel(1)
		-- 设置操作信息：这张卡回到额外卡组
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
	else
		e:SetLabel(0)
	end
	local cat=0
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then cat=cat|CATEGORY_SPECIAL_SUMMON|CATEGORY_MSET end
	if g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then cat=cat|CATEGORY_SSET end
	if g:IsExists(s.cspfilter,1,nil) then cat=cat|CATEGORY_GRAVE_SPSUMMON end
	if g:GetCount()>=2 then cat=cat|CATEGORY_TOEXTRA end
	e:SetCategory(cat)
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if gg:GetCount()>0 then
		-- 设置操作信息：墓地中的对象卡将离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,gg:GetCount(),0,0)
	end
end
-- ②效果处理：对象卡各加入手卡或在自己场上盖放（怪兽里侧守备表示特殊召唤、陷阱卡盖放），以2张为对象的场合再让这张卡回到额外卡组
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得与当前连锁关联的对象卡组
	local g=Duel.GetTargetsRelateToChain()
	-- 若对象卡受王家长眠之谷影响，则无效该效果并中止处理
	if aux.NecroValleyNegateCheck(g) then return end
	-- 过滤出不受王家长眠之谷影响的对象卡
	local sg=g:Filter(aux.NecroValleyFilter(),nil)
	if sg:GetCount()==1 then
		local tc=sg:GetFirst()
		local set=s.setfilter(tc,e,tp)
		if tc:IsAbleToHand()
			-- 若该卡不能盖放，或玩家选择「加入手卡」的选项
			and (not set or Duel.SelectOption(tp,1190,1153)==0) then
			-- 把该卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示该卡
			Duel.ConfirmCards(1-tp,tc)
		elseif set then
			if tc:IsType(TYPE_MONSTER) then
				-- 把该怪兽在自己场上里侧守备表示特殊召唤（即盖放到怪兽区域）
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 向对方玩家展示该卡
				Duel.ConfirmCards(1-tp,tc)
			else
				-- 把该陷阱卡在自己场上盖放
				Duel.SSet(tp,tc)
			end
		end
	elseif sg:GetCount()==2 then
		local tg=sg:Filter(s.setfilter,nil,e,tp)
		local setg=Group.CreateGroup()
		if tg:GetCount()>0 then
			local selg=Group.CreateGroup()
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			while true do
				local mct=selg:FilterCount(Card.IsType,nil,TYPE_MONSTER)
				local tct=selg:FilterCount(Card.IsType,nil,TYPE_TRAP)
				local finish=true
				if mct>0 then
					-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
					if Duel.IsPlayerAffectedByEffect(tp,59822133) and mct>1 or mct>Duel.GetLocationCount(tp,LOCATION_MZONE) then
						finish=false
					end
				end
				-- 已选择盖放的陷阱卡数量超过魔法与陷阱区域的空格数时，不允许完成选择
				if tct>0 and tct>Duel.GetLocationCount(tp,LOCATION_SZONE) then
					finish=false
				end
				local tmg=tg:Clone()
				tmg:Sub(selg)
				local tc=tmg:SelectUnselect(selg,tp,finish,false,1,tg:GetCount())
				if not tc then
					setg:Merge(selg)
					break
				end
				if selg:IsContains(tc) then
					selg:RemoveCard(tc)
				else
					selg:AddCard(tc)
				end
			end
		end
		local thg=sg-setg
		if thg:GetCount()>0 then
			-- 把其余未盖放的卡加入手卡
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			-- 向对方玩家展示这些卡
			Duel.ConfirmCards(1-tp,thg)
		end
		local msg=setg:Filter(Card.IsType,nil,TYPE_MONSTER)
		if msg:GetCount()>0 then
			-- 把选择盖放的怪兽在自己场上里侧守备表示特殊召唤
			Duel.SpecialSummon(msg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			if msg:GetCount()==1 then
				-- 只有1只时向对方玩家展示该怪兽
				Duel.ConfirmCards(1-tp,msg)
			end
		end
		local ssg=setg:Filter(Card.IsType,nil,TYPE_TRAP)
		if ssg:GetCount()>0 then
			-- 把选择盖放的陷阱卡在自己场上盖放
			Duel.SSet(tp,ssg)
		end
	end
	if e:GetLabel()==1 and sg:GetCount()>0 and c:IsRelateToChain() then
		-- 中断当前效果，使回到额外卡组与之前的处理不同时处理
		Duel.BreakEffect()
		-- 把这张卡回到额外卡组（并洗切额外卡组）
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

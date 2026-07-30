--鬼神 朱沙之王
local s,id,o=GetID()
-- 为鬼神 朱沙之王添加同调召唤手续并注册两个效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果1：当此卡特殊召唤成功时发动，可以除外场上1张卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	-- 效果2：在结束阶段发动，可以选择墓地或除外区的1~2张卡进行操作
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
-- 效果1的发动条件：此卡必须是同调召唤成功
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤器函数：用于筛选墓地中的陷阱卡作为除外费用
function s.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果1的费用处理：从墓地选择至少1张陷阱卡除外作为费用
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算场上可除外的卡的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 检查是否满足费用条件：墓地中存在至少1张陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中的陷阱卡作为除外费用
	local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- 效果1的目标设定：确认费用已支付并检查场上是否存在可除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在至少1张可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可除外的卡组成的组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，准备将指定数量的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,e:GetLabel(),0,0)
end
-- 效果1的处理：选择场上1张卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 检查场上是否还有足够的卡可以除外
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)<ct then return end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上可除外的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	if #sg>0 then
		-- 显示选中的卡被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤器函数：用于筛选鬼神族的怪兽或陷阱卡，可以送去手牌或特殊召唤/盖放
function s.tgfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER+TYPE_TRAP)
		and (c:IsAbleToHand() or s.setfilter(c,e,tp))
end
-- 过滤器函数：用于判断卡是否可以特殊召唤或盖放
function s.setfilter(c,e,tp)
	-- 判断卡是否为怪兽且可以特殊召唤到场上
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		or c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 过滤器函数：用于筛选墓地中的怪兽卡
function s.cspfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE)
end
-- 效果2的目标设定：选择墓地或除外区的1~2张卡作为操作对象
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tgfilter(chkc,e,tp) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	local ct=1
	if c:IsAbleToExtra() then ct=2 end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil,e,tp)
	if g:GetCount()==2 then
		e:SetLabel(1)
		-- 设置操作信息，准备将此卡送回额外卡组
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
		-- 设置操作信息，准备将选中的墓地卡离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,gg:GetCount(),0,0)
	end
end
-- 效果2的处理：根据选择的卡数量进行不同的处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的选中目标卡组
	local g=Duel.GetTargetsRelateToChain()
	-- 检查目标卡组是否受到王家长眠之谷的影响
	if aux.NecroValleyNegateCheck(g) then return end
	-- 过滤掉受王家长眠之谷影响的卡，只保留可操作的卡
	local sg=g:Filter(aux.NecroValleyFilter(),nil)
	if sg:GetCount()==1 then
		local tc=sg:GetFirst()
		local set=s.setfilter(tc,e,tp)
		if tc:IsAbleToHand()
			-- 判断是否选择将卡送去手牌或特殊召唤/盖放
			and (not set or Duel.SelectOption(tp,1190,1153)==0) then
			-- 将卡送入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对手能看到该卡
			Duel.ConfirmCards(1-tp,tc)
		elseif set then
			if tc:IsType(TYPE_MONSTER) then
				-- 将卡特殊召唤到场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 确认对手能看到该卡
				Duel.ConfirmCards(1-tp,tc)
			else
				-- 将卡盖放在场上
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
				-- 检查是否超出场上可用魔法陷阱区域数量
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
			-- 将剩余的卡送入手牌
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			-- 确认对手能看到这些卡
			Duel.ConfirmCards(1-tp,thg)
		end
		local msg=setg:Filter(Card.IsType,nil,TYPE_MONSTER)
		if msg:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(msg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			if msg:GetCount()==1 then
				-- 确认对手能看到该卡
				Duel.ConfirmCards(1-tp,msg)
			end
		end
		local ssg=setg:Filter(Card.IsType,nil,TYPE_TRAP)
		if ssg:GetCount()>0 then
			-- 将选中的陷阱卡盖放在场上
			Duel.SSet(tp,ssg)
		end
	end
	if e:GetLabel()==1 and sg:GetCount()>0 and c:IsRelateToChain() then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 将此卡送回卡组顶部并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

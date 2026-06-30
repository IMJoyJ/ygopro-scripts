--R.B. Shepherd's Crook
-- 效果：
-- 包含「奏悦机组」怪兽的怪兽2只以上
-- 这张卡的攻击力上升这张卡以外的自己怪兽的数量×500。
-- 「奏悦机组 牧羊人权杖」的以下效果1回合各能使用1次。
-- 自己主要阶段：可以从自己的卡组·墓地把1张「奏悦机组」陷阱卡在自己场上盖放。
-- 对方主要阶段（诱发即时效果）：可以以自己墓地的3只3星以上的「奏悦机组」怪兽为对象；那之内的2只用喜欢的顺序回到卡组最下面，剩下的守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册连接召唤手续、提升自身攻击力，以及①主要阶段盖放陷阱和②对方主要阶段回卡组并特召的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册连接召唤的手续：2只或3只怪兽作为连接素材，且包含「奏悦机组」怪兽
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- 这张卡的攻击力上升这张卡以外的自己怪兽的数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 自己主要阶段：可以从自己的卡组·墓地把1张「奏悦机组」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"盖放陷阱"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 对方主要阶段（诱发即时效果）：可以以自己墓地的3只3星以上的「奏悦机组」怪兽为对象；那之内的2只用喜欢的顺序回到卡组最下面，剩下的守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到卡组并特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接召唤素材检查：所选的怪兽组中必须包含至少1只「奏悦机组」怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1cf)
end
-- 攻击力上升数值计算：统计自身场上除自身以外的怪兽数量，并乘以500
function s.atkval(e,c)
	-- 计算自己场上除自身以外的其他怪兽数量乘以500的数值
	return Duel.GetMatchingGroupCount(aux.TRUE,c:GetControler(),LOCATION_MZONE,0,e:GetHandler())*500
end
-- 过滤条件：卡组或墓地中可以盖放的「奏悦机组」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动的目标检查：检查魔陷区是否有空位，以及卡组或墓地是否存在符合条件的「奏悦机组」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法·陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或墓地中是否存在可以盖放的「奏悦机组」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果处理的操作：从卡组或墓地选择1张「奏悦机组」陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己的卡组或墓地中选择1张符合条件的「奏悦机组」陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 触发条件判定：当前必须是对方的回合且是主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 过滤条件：墓地中3星以上、可以成为效果对象、可以回到卡组或可以特殊召唤的「奏悦机组」怪兽
function s.tdfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsLevelAbove(3)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 组过滤条件：在选定的3张卡中，必须有至少2只可以回到卡组，且至少1只可以守备表示特殊召唤
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsAbleToDeck,2,nil) and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标检查与选择：在墓地选择3只符合条件的怪兽，注册为连锁对象，并设置回到卡组与特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有满足条件的「奏悦机组」怪兽
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 检查墓地中是否存在符合条件的三张卡组合，且自己场上有可用的主要怪兽区
	if chk==0 then return dg:CheckSubGroup(s.fselect,3,3,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,s.fselect,false,3,3,e,tp)
	-- 将选中的3只墓地怪兽设定为效果的对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息：将其中2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置当前连锁的操作信息：特殊召唤其中1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：可以守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 第二阶段选择过滤条件：在处理时确认选择2张可洗回卡组的卡，并保证剩余的1张能成功特召（在怪兽区有空位的前提下）
function s.fselect2(g,e,tp,sg)
	local ag=sg:Clone()
	ag:Sub(g)
	-- 判断选中的2张卡是否可以洗回卡组，且自身场上存在可用区域使得剩余的卡可以被特召
	return g:IsExists(Card.IsAbleToDeck,2,nil) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ag:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		or not sg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 或者在场上没有可用主要怪兽区的情况下（即只能放回卡组，无法特召）
		or Duel.GetLocationCount(tp,LOCATION_MZONE)==0)
end
-- 效果处理的操作：在作为对象的3只怪兽中选择2只洗回卡组最下面，剩余的1只以守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取依然与该连锁相关且不受王之谷影响的对象怪兽
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()<2 then
		return
	elseif tg:GetCount()==2 and tg:IsExists(Card.IsAbleToDeck,2,nil) then
		-- 将所选的卡片以自选的顺序放置到卡组底端
		aux.PlaceCardsOnDeckBottom(tp,tg)
	-- 若对象卡片全部有效且自己场上有空位，则准备从中进行选择
	elseif tg:GetCount()>2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要返回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:SelectSubGroup(tp,s.fselect2,false,2,2,e,tp,tg)
		if sg:GetCount()>0 then
			tg:Sub(sg)
			-- 在画面上显示被选择返回卡组的对象卡片
			Duel.HintSelection(sg)
			-- 将选出来的2张卡放置到卡组底端
			aux.PlaceCardsOnDeckBottom(tp,sg)
			-- 获取刚才实际送回卡组的卡片组
			local og=Duel.GetOperatedGroup()
			if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
			local tc=tg:GetFirst()
			-- 检查当前场上是否仍有可用的怪兽区空间
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 将剩余的那1只怪兽在自己场上以表侧守备表示特殊召唤
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end

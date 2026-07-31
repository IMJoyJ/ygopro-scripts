--R.B.シェパード・クルーク
-- 效果：
-- 包含「奏悦机组」怪兽的怪兽2只以上
-- 这张卡的攻击力上升这张卡以外的自己怪兽的数量×500。
-- 「奏悦机组 牧羊人权杖」的以下效果1回合各能使用1次。
-- 自己主要阶段：可以从自己的卡组·墓地把1张「奏悦机组」陷阱卡在自己场上盖放。
-- 对方主要阶段（诱发即时效果）：可以以自己墓地的3只3星以上的「奏悦机组」怪兽为对象；那之内的2只用喜欢的顺序回到卡组最下面，剩下的守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：启用常规召唤手续、注册Link召唤手续、①攻击力上升效果、②盖放「奏悦机组」陷阱效果、③墓地怪兽回到卡组并特召效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册Link召唤手续：包含「奏悦机组」怪兽在内的怪兽2~3只
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
	-- 对方主要阶段：可以以自己墓地的3只3星以上的「奏悦机组」怪兽为对象；那之内的2只用喜欢的顺序回到卡组最下面，剩下的守备表示特殊召唤。
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
-- Link素材检查：素材中必须包含至少1只「奏悦机组」怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1cf)
end
-- 攻击力上升数值计算：除自身外的自己场上怪兽数量×500
function s.atkval(e,c)
	-- 统计自己场上除此卡以外的怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(aux.TRUE,c:GetControler(),LOCATION_MZONE,0,e:GetHandler())*500
end
-- 盖放陷阱过滤条件：「奏悦机组」陷阱卡且能在场上盖放
function s.setfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动准备：检查魔法与陷阱区域空位及卡组/墓地目标卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或墓地是否存在可盖放的「奏悦机组」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ②效果处理：从卡组或墓地选1张「奏悦机组」陷阱卡在场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择1张满足条件的「奏悦机组」陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- ③效果发动条件：对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前为对方回合且处于主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 墓地目标卡过滤条件：墓地的3星以上「奏悦机组」怪兽
function s.tdfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsLevelAbove(3)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 目标卡组合检查：3张卡中至少2张能回到卡组且至少1张能特召
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsAbleToDeck,2,nil) and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果发动准备：选择墓地3只目标怪兽并设置返回卡组与特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取墓地中所有满足条件的「奏悦机组」怪兽
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 发动条件检查：墓地有符合条件的3张卡且怪兽区域有空位
	if chk==0 then return dg:CheckSubGroup(s.fselect,3,3,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要操作的3张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,s.fselect,false,3,3,e,tp)
	-- 将选中的3张卡设为效果对象
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息：2张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置连锁操作信息：1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤过滤条件：可以守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 选为返回卡组的2张卡组合验证
function s.fselect2(g,e,tp,sg)
	local ag=sg:Clone()
	ag:Sub(g)
	-- 验证选出的2张卡可回到卡组，且剩余1张卡满足特召条件
	return g:IsExists(Card.IsAbleToDeck,2,nil) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ag:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		or not sg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 兼顾怪兽区域无空位时的极端情况判断
		or Duel.GetLocationCount(tp,LOCATION_MZONE)==0)
end
-- ③效果处理：将对象中的2张卡放回卡组最下面，剩余1张守备表示特召
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍关联且不受墓谷影响的目标卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()<2 then
		return
	elseif tg:GetCount()==2 and tg:IsExists(Card.IsAbleToDeck,2,nil) then
		-- 仅剩2张有效目标时，直接将2张卡放回卡组最下面
		aux.PlaceCardsOnDeckBottom(tp,tg)
	-- 3张目标均有效且怪兽区域有空位时的处理
	elseif tg:GetCount()>2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要返回卡组的2张卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:SelectSubGroup(tp,s.fselect2,false,2,2,e,tp,tg)
		if sg:GetCount()>0 then
			tg:Sub(sg)
			-- 高亮显示选择返回卡组的卡
			Duel.HintSelection(sg)
			-- 将选中的2张卡按喜好顺序放回卡组最下面
			aux.PlaceCardsOnDeckBottom(tp,sg)
			-- 获取实际放回卡组的卡
			local og=Duel.GetOperatedGroup()
			if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
			local tc=tg:GetFirst()
			-- 检查怪兽区域是否仍有空位
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 将剩余的1张卡表侧守备表示特殊召唤
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end

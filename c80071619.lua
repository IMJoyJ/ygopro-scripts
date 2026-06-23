--R.B. Shepherd's Crook
-- 效果：
-- 包含「奏悦机组」怪兽的怪兽2只以上
-- 这张卡的攻击力上升这张卡以外的自己怪兽的数量×500。
-- 「奏悦机组 牧羊人权杖」的以下效果1回合各能使用1次。
-- 自己主要阶段：可以从自己的卡组·墓地把1张「奏悦机组」陷阱卡在自己场上盖放。
-- 对方主要阶段（诱发即时效果）：可以以自己墓地的3只3星以上的「奏悦机组」怪兽为对象；那之内的2只用喜欢的顺序回到卡组最下面，剩下的守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：2-3只怪兽，且需满足s.lcheck过滤条件
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
-- 连接素材检查：素材中必须包含至少1只「奏悦机组」怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1cf)
end
-- 攻击力上升值的计算函数
function s.atkval(e,c)
	-- 返回自己场上除这张卡以外的怪兽数量乘以500的数值
	return Duel.GetMatchingGroupCount(aux.TRUE,c:GetControler(),LOCATION_MZONE,0,e:GetHandler())*500
end
-- 过滤卡组或墓地中可盖放的「奏悦机组」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的发动准备与合法性检查（Target函数）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或墓地是否存在可盖放的「奏悦机组」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 盖放效果的执行逻辑（Operation函数）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择1张满足条件的「奏悦机组」陷阱卡（受墓地限制效果影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 诱发即时效果的发动条件检查函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 过滤墓地中可作为对象的3星以上「奏悦机组」怪兽
function s.tdfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsLevelAbove(3)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 检查选中的3张卡中是否包含至少2只可回卡组的怪兽和至少1只可特殊召唤的怪兽
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsAbleToDeck,2,nil) and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 回卡组并特召效果的发动准备与对象选择（Target函数）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有满足条件的「奏悦机组」怪兽
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 检查墓地中是否存在满足条件的3张卡，且自己场上有可用于特殊召唤的怪兽区域空位
	if chk==0 then return dg:CheckSubGroup(s.fselect,3,3,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,s.fselect,false,3,3,e,tp)
	-- 将选中的3张卡注册为效果的对象
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息：预计将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置连锁操作信息：预计将1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查在效果处理时，选定返回卡组的2张卡后，剩下的卡是否依然能合法特殊召唤
function s.fselect2(g,e,tp,sg)
	local ag=sg:Clone()
	ag:Sub(g)
	-- 检查选出的2张卡是否能回到卡组，且在有怪兽区域空位时，剩下的1张卡是否能守备表示特殊召唤
	return g:IsExists(Card.IsAbleToDeck,2,nil) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ag:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		or not sg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 或者此时自己场上已没有可用的怪兽区域空位
		or Duel.GetLocationCount(tp,LOCATION_MZONE)==0)
end
-- 回卡组并特召效果的执行逻辑（Operation函数）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()<2 then
		return
	elseif tg:GetCount()==2 and tg:IsExists(Card.IsAbleToDeck,2,nil) then
		-- 将这2张对象卡以玩家喜欢的顺序回到卡组最下面
		aux.PlaceCardsOnDeckBottom(tp,tg)
	-- 如果3张对象卡都合法，且自己场上有可用的怪兽区域空位
	elseif tg:GetCount()>2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:SelectSubGroup(tp,s.fselect2,false,2,2,e,tp,tg)
		if sg:GetCount()>0 then
			tg:Sub(sg)
			-- 确认并显示选中的要送回卡组的2张卡
			Duel.HintSelection(sg)
			-- 将选中的2张卡以喜欢的顺序回到卡组最下面
			aux.PlaceCardsOnDeckBottom(tp,sg)
			-- 获取上一步实际操作（回到卡组）的卡片组
			local og=Duel.GetOperatedGroup()
			if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
			local tc=tg:GetFirst()
			-- 检查自己场上是否仍有可用的怪兽区域空位
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 将剩下的1张对象怪兽以守备表示特殊召唤
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end

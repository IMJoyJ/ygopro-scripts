--R.B.シェパード・クルーク
-- 效果：
-- 包含「奏悦机组」怪兽的怪兽2只以上
-- 这张卡的攻击力上升这张卡以外的自己怪兽的数量×500。
-- 「奏悦机组 牧羊人权杖」的以下效果1回合各能使用1次。
-- 自己主要阶段：可以从自己的卡组·墓地把1张「奏悦机组」陷阱卡在自己场上盖放。
-- 对方主要阶段（诱发即时效果）：可以以自己墓地的3只3星以上的「奏悦机组」怪兽为对象；那之内的2只用喜欢的顺序回到卡组最下面，剩下的守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册这张卡的连接召唤手续及各个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要2至3只包含「反叛曲机器人」怪兽的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- ①：这张卡的攻击力上升自己场上的其他怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1张「反叛曲机器人」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"盖放陷阱"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：对方主要阶段，以自己墓地3只3星以上的「反叛曲机器人」怪兽为对象才能发动。那之内的2只用喜欢的顺序回到卡组下面，另1只守备表示特殊召唤。
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
-- 连接素材过滤条件：作为连接素材时至少有1只包含「反叛曲机器人」字段
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1cf)
end
-- 效果处理：计算这张卡上升的攻击力
function s.atkval(e,c)
	-- 获取除了这张卡以外的自己主要怪兽区的怪兽数量，并乘以500
	return Duel.GetMatchingGroupCount(aux.TRUE,c:GetControler(),LOCATION_MZONE,0,e:GetHandler())*500
end
-- 过滤条件：「反叛曲机器人」陷阱卡，且能够盖放
function s.setfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果对象和操作信息设置：判断能否在魔陷区盖放以及卡组或墓地是否有符合条件的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己卡组或墓地是否存在至少1张满足条件的「反叛曲机器人」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果处理：从自己的卡组·墓地把1张「反叛曲机器人」陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示消息，让玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从自己卡组或墓地中选择1张符合条件且不受王家长眠之谷影响的「反叛曲机器人」陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 触发条件：对方主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为对方回合，并且处于主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 过滤条件：3星以上的「反叛曲机器人」怪兽，能成为对象，且可以回到卡组或能够被守备表示特殊召唤
function s.tdfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsLevelAbove(3)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 对象组合合法性判断：组内必须至少有2张卡能回到卡组，且至少有1张卡能被特招
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsAbleToDeck,2,nil) and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果对象和操作信息设置：以自己墓地3只3星以上的「反叛曲机器人」怪兽为对象，设置相关操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取墓地中所有满足基本过滤条件的卡
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 检查墓地是否能选出满足子群判定条件的3张卡，且自己怪兽区有空格
	if chk==0 then return dg:CheckSubGroup(s.fselect,3,3,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 发送提示消息：请选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,s.fselect,false,3,3,e,tp)
	-- 把这3张选定的卡设为效果对象
	Duel.SetTargetCard(g)
	-- 设置操作信息：包含回到卡组的效果，预计处理2张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置操作信息：包含特殊召唤效果，预计特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：能够被守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 子群合法性判断：选出的2张卡必须能回到卡组，根据场上格子和剩余卡片状态判断是否合法
function s.fselect2(g,e,tp,sg)
	local ag=sg:Clone()
	ag:Sub(g)
	-- 选出的2张卡必须能回卡组，且若怪兽区有空格则剩下的卡必须能被特殊召唤
	return g:IsExists(Card.IsAbleToDeck,2,nil) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ag:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		or not sg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 或者自己场上没有可用的怪兽区空格
		or Duel.GetLocationCount(tp,LOCATION_MZONE)==0)
end
-- 效果处理：将选中的对象中的2只回到卡组最下面，剩下的特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍在墓地且不受王家长眠之谷影响的对象卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()<2 then
		return
	elseif tg:GetCount()==2 and tg:IsExists(Card.IsAbleToDeck,2,nil) then
		-- 如果剩余对象只有2个且都能回卡组，直接将它们放回卡组底
		aux.PlaceCardsOnDeckBottom(tp,tg)
	-- 如果对象依然有3个且自己怪兽区有空格
	elseif tg:GetCount()>2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 发送提示消息，让玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:SelectSubGroup(tp,s.fselect2,false,2,2,e,tp,tg)
		if sg then
			tg:Sub(sg)
			-- 手动为即将回卡组的卡显示被选为对象的动画
			Duel.HintSelection(sg)
			-- 将选定的2张卡以自己喜欢的顺序放到卡组最下面
			aux.PlaceCardsOnDeckBottom(tp,sg)
			-- 获取实际操作（回到卡组）的卡片组
			local og=Duel.GetOperatedGroup()
			if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
			local tc=tg:GetFirst()
			-- 检查自己场上是否还有可用的怪兽区空格
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 把剩下的那只怪兽表侧守备表示特殊召唤到自己场上
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end

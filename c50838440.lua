--三位一体
-- 效果：
-- ①：对方结束阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多的场合才能发动。从自己墓地把3只通常怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以原本卡名不同的自己场上3张怪兽卡为对象才能发动。把有那3张卡的原本卡名全部记述的1张魔法·陷阱卡从手卡·卡组到自己场上盖放。
local s,id,o=GetID()
-- 注册两个效果，第一个为发动时点效果，第二个为墓地发动的诱发即时效果
function s.initial_effect(c)
	-- ①：对方结束阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多的场合才能发动。从自己墓地把3只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以原本卡名不同的自己场上3张怪兽卡为对象才能发动。把有那3张卡的原本卡名全部记述的1张魔法·陷阱卡从手卡·卡组到自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 效果条件：对方结束阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多
	return Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)<Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE+LOCATION_HAND,nil)
		-- 当前为结束阶段且不是自己回合
		and Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：满足条件的通常怪兽
function s.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动判定：检测是否受青眼精灵龙影响、场上是否有足够空间、墓地是否有3只符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 墓地是否存在3只符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤3只怪兽到自己场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的处理：检查召唤区域是否足够、是否受青眼精灵龙影响、选择并特殊召唤3只怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择3只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：满足条件的场上的怪兽，且其原本类型为怪兽，并且存在后续目标
function s.thfilter1(c,tp)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER and c:IsFaceup()
		-- 检查是否存在满足条件的第二目标
		and Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_ONFIELD,0,1,nil,tp,c)
end
-- 过滤函数：满足条件的场上的怪兽，且其原本卡号与第一目标不同，并且其原本类型为怪兽，并且存在后续目标
function s.thfilter2(c,tp,oc)
	return not c:IsOriginalCodeRule(oc:GetOriginalCode()) and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER and c:IsFaceup()
		-- 检查是否存在满足条件的第三目标
		and Duel.IsExistingTarget(s.thfilter3,tp,LOCATION_ONFIELD,0,1,nil,tp,oc,c)
end
-- 过滤函数：满足条件的场上的怪兽，且其原本卡号与前两个目标都不同，并且其原本类型为怪兽，并且存在后续可盖放的魔法陷阱卡
function s.thfilter3(c,tp,oc,tc)
	return not c:IsOriginalCodeRule(oc:GetOriginalCode(),tc:GetOriginalCode()) and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER and c:IsFaceup()
		-- 检查是否存在满足条件的魔法陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp,oc,tc,c)
end
-- 过滤函数：满足条件的魔法陷阱卡，其效果文本记载了三个目标的原本卡号，并且可以盖放
function s.setfilter(c,tp,oc,tc,sc)
	-- 判断该魔法陷阱卡是否记载了三个目标的原本卡号
	return aux.IsCodeListed(c,oc:GetOriginalCode()) and aux.IsCodeListed(c,tc:GetOriginalCode()) and aux.IsCodeListed(c,sc:GetOriginalCode())
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsSSetable()
end
-- 盖放效果的发动判定：检查场上是否有足够的盖放区域、是否存在满足条件的目标怪兽
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否有足够的盖放区域、是否存在满足条件的第一目标
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择第一目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第一目标
	local g=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	local oc=g:GetFirst()
	-- 提示玩家选择第二目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第二目标
	local g2=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_ONFIELD,0,1,1,nil,tp,oc)
	local tc=g2:GetFirst()
	-- 提示玩家选择第三目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第三目标
	Duel.SelectTarget(tp,s.thfilter3,tp,LOCATION_ONFIELD,0,1,1,nil,tp,oc,tc)
end
-- 盖放效果的处理：获取选中的三个目标、提示玩家选择要盖放的魔法陷阱卡并进行盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选中的卡片组，并筛选出与当前效果相关的且处于表侧表示的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	if tg:GetCount()~=3 then return end
	local oc=tg:GetFirst()
	local tc=tg:GetNext()
	local sc=tg:GetNext()
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从手牌或卡组中选择满足条件的魔法陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp,oc,tc,sc)
	if g:GetCount()>0 then
		-- 将选中的魔法陷阱卡盖放到场上
		Duel.SSet(tp,g:GetFirst())
	end
end

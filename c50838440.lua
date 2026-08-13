--三位一体
-- 效果：
-- ①：对方结束阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多的场合才能发动。从自己墓地把3只通常怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以原本卡名不同的自己场上3张怪兽卡为对象才能发动。把有那3张卡的原本卡名全部记述的1张魔法·陷阱卡从手卡·卡组到自己场上盖放。
local s,id,o=GetID()
-- 注册三位一体的两个效果：①为魔法发动效果，条件为对方结束阶段且对方手牌+场上卡数多于自己，从墓地特殊召唤3只通常怪兽；②为墓地二速效果，除外自身，以自己场上3张原本卡名不同的表侧怪兽为对象，从手牌·卡组将1张记载了这些卡名的魔法陷阱卡盖放。
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
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：对方回合结束阶段，且对方的手牌和场上怪兽区卡数合计多于自己的手牌和场上怪兽区卡数合计。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己手牌与场上怪兽区卡数合计小于对方手牌与场上怪兽区卡数合计。
	return Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)<Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE+LOCATION_HAND,nil)
		-- 并且当前阶段为结束阶段，且当前回合玩家不是自己（即对方结束阶段）。
		and Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()~=tp
end
-- 墓地怪兽的筛选条件：该怪兽是通常怪兽，且能够被当前效果特殊召唤（满足召唤条件和苏生限制）。
function s.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动合法性检查：不取对象，需满足未被青眼精灵龙的压制效果影响、自己场上有至少3个可用怪兽区空格、墓地存在至少3只符合条件的通常怪兽；并登记特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己场上（主要怪兽区）有至少3个可用的空格，以容纳3只特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 确认墓地中存在至少3只满足 s.filter 条件的通常怪兽可供选择。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 设置当前连锁的处理信息：本效果将把3只怪兽从墓地特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end
-- 结算①效果：处理时再确认场上空位和青眼精灵龙效果，从自己墓地选择3只满足条件且不受王家长眠之谷影响的通常怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上可用怪兽区域不超过2个，则无法特殊召唤3只怪兽，效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择3张满足特殊召唤条件且不受王家长眠之谷影响的通常怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选②效果的第一个对象：表侧表示的怪兽（原始类型为怪兽），并且场上还存在另外两张可达成条件的目标。
function s.thfilter1(c,tp)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER and c:IsFaceup()
		-- 检测场上是否存在第二张满足 thfilter2 条件的表侧表示怪兽。
		and Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_ONFIELD,0,1,nil,tp,c)
end
-- 筛选②效果的第二个对象：表侧表示怪兽，原始卡名与第一个对象不同，并且场上还存在第三张可达成条件的目标。
function s.thfilter2(c,tp,oc)
	return not c:IsOriginalCodeRule(oc:GetOriginalCode()) and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER and c:IsFaceup()
		-- 检测场上是否存在第三张满足 thfilter3 条件的表侧表示怪兽。
		and Duel.IsExistingTarget(s.thfilter3,tp,LOCATION_ONFIELD,0,1,nil,tp,oc,c)
end
-- 筛选②效果的第三个对象：表侧表示怪兽，原始卡名与前两个对象均不同，并且手牌·卡组中存在一张记载这三个卡名的可盖放魔陷。
function s.thfilter3(c,tp,oc,tc)
	return not c:IsOriginalCodeRule(oc:GetOriginalCode(),tc:GetOriginalCode()) and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER and c:IsFaceup()
		-- 检测手牌·卡组中是否存在满足 setfilter 条件的魔法陷阱卡。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp,oc,tc,c)
end
-- 筛选可盖放的魔法陷阱卡：其效果文本中同时记载了三个对象怪兽的原本卡名，且自身是魔法陷阱卡并可以被盖放。
function s.setfilter(c,tp,oc,tc,sc)
	-- 该魔法陷阱卡的效果文本中记载了三个对象怪兽的原本卡名（用 aux.IsCodeListed 检测）。
	return aux.IsCodeListed(c,oc:GetOriginalCode()) and aux.IsCodeListed(c,tc:GetOriginalCode()) and aux.IsCodeListed(c,sc:GetOriginalCode())
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsSSetable()
end
-- ②效果的发动目标处理：检查魔陷区空位并选择3张表侧表示、原始卡名互不相同的怪兽作为对象（依次选择并登记）。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时检测：自己魔陷区有可用空格，且场上存在至少一组满足条件的3张表侧表示怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 显示选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第一个对象（表侧表示怪兽）并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	local oc=g:GetFirst()
	-- 显示选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第二个对象，并确保其原始卡名与第一个对象不同。
	local g2=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_ONFIELD,0,1,1,nil,tp,oc)
	local tc=g2:GetFirst()
	-- 显示选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第三个对象，并确保其原始卡名与前两个对象均不同。
	Duel.SelectTarget(tp,s.thfilter3,tp,LOCATION_ONFIELD,0,1,1,nil,tp,oc,tc)
end
-- 结算②效果：从连锁中取得三个对象并过滤出仍相关且表侧表示的怪兽，若仍有3张，则从手牌·卡组选择一张记载这三个原本卡名的魔法陷阱卡盖放到自己魔陷区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象卡组，筛选出仍与效果存在关联且表侧表示的怪兽。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	if tg:GetCount()~=3 then return end
	local oc=tg:GetFirst()
	local tc=tg:GetNext()
	local sc=tg:GetNext()
	-- 显示选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从手牌·卡组选择1张满足 setfilter 条件的魔法陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp,oc,tc,sc)
	if g:GetCount()>0 then
		-- 将选择的魔法陷阱卡盖放到自己场上（魔陷区）。
		Duel.SSet(tp,g:GetFirst())
	end
end

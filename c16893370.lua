--夢現の寝姫－ネムレリア・レアリゼ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合，可以从以下效果选择1个发动。
-- ●从卡组把1只「梦见之妮穆蕾莉娅」表侧加入额外卡组。
-- ●场上1只其他的表侧表示怪兽变成里侧守备表示。
-- ③：这张卡的攻击力上升自己的额外卡组的里侧的卡数量×100。
local s,id,o=GetID()
-- 注册三个效果：e1为③攻击力上升的永续效果，e2为①手牌起动效果（回卡组底并特殊召唤），e3为②特殊召唤成功时触发并可二选一的效果。
function s.initial_effect(c)
	-- ③：这张卡的攻击力上升自己的额外卡组的里侧的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在的场合，以自己场上1只怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合，可以从以下效果选择1个发动。●从卡组把1只「梦见之妮穆蕾莉娅」表侧加入额外卡组。●场上1只其他的表侧表示怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升数值的计算函数：统计自身控制者额外卡组里侧表示的卡数量并乘以100。
function s.atkval(e,c)
	-- 返回自己额外卡组里侧表示的卡数量×100，作为③的攻击力上升数值。
	return Duel.GetMatchingGroupCount(Card.IsFacedown,c:GetControler(),LOCATION_EXTRA,0,nil)*100
end
-- 定义①效果中可作为对象的怪兽的筛选条件：该怪兽离开后自己场上仍有空余怪兽区，且该怪兽可以被效果送回卡组。
function s.filter(c,tp)
	-- 判断该怪兽离开后自己的怪兽区仍有空格，且该怪兽能够返回卡组。
	return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToDeck()
end
-- ①效果的发动条件和取对象合法性判断：取对象时需选择自己场上的怪兽，且该怪兽满足s.filter；发动时需存在满足条件的对象，且这张卡在手牌可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 发动时检查：自己场上是否存在1只满足返回卡组条件的怪兽可作为对象，以及这张卡能够特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 向玩家提示“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己场上选择1只满足s.filter条件的怪兽作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记操作信息：将选择的对象怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 登记操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：对象怪兽返回卡组最下面后，若这张卡仍与效果关联且自己场上有空位，则将其表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与当前效果关联，并将其送回持有者卡组最下面；若实际返回成功则继续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 确认这张卡仍与效果关联且自己场上有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义「梦见之妮穆蕾莉娅」的筛选条件：卡号为70155677、是灵摆怪兽且未被禁止。
function s.edfilter(c)
	return c:IsCode(70155677) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 定义可变成里侧守备表示的怪兽的筛选条件：表侧表示且可以被变为里侧守备表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的发动条件与选项选择：若卡组存在可加入额外卡组的「梦见之妮穆蕾莉娅」，或场上存在其他可变为里侧守备表示的怪兽，则让玩家二选一，并动态设置效果类别和操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得卡组中满足edfilter条件的「梦见之妮穆蕾莉娅」的集合。
	local g1=Duel.GetMatchingGroup(s.edfilter,tp,LOCATION_DECK,0,nil)
	-- 取得场上除自身以外、满足posfilter条件的其他表侧表示怪兽的集合。
	local g2=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g1>0 or #g2>0 end
	e:SetCategory(0)
	local off=1
	local ops={}
	local opval={}
	if #g1>0 then
		ops[off]=aux.Stringid(id,2)  --"加入额外卡组"
		opval[off]=0
		off=off+1
	end
	if #g2>0 then
		ops[off]=aux.Stringid(id,3)  --"变成里侧守备"
		opval[off]=1
		off=off+1
	end
	-- 让玩家在“加入额外卡组”和“变成里侧守备”两个选项中选择一个，返回序号加1以对应opval。
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_TOEXTRA)
		-- 登记操作信息：从卡组将1张卡表侧加入额外卡组。
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
	elseif sel==1 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
		-- 登记操作信息：将1只其他怪兽变成里侧守备表示。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g2,1,0,0)
	end
end
-- ②效果处理：根据目标阶段选择的选项执行——若选0则从卡组选1只「梦见之妮穆蕾莉娅」表侧加入额外卡组；若选1则选场上其他1只表侧表示怪兽变成里侧守备表示。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 向玩家提示“请选择要操作的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组选择1只满足edfilter条件的「梦见之妮穆蕾莉娅」。
		local g=Duel.SelectMatchingCard(tp,s.edfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选择的卡以表侧表示加入额外卡组。
			Duel.SendtoExtraP(g,nil,REASON_EFFECT)
		end
	elseif sel==1 then
		-- 向玩家提示“请选择要改变表示形式的怪兽”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择场上除自身以外的1只表侧表示且可变为里侧守备表示的怪兽，排除当前效果关联的自身。
		local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e))
		if #sg>0 then
			-- 显示选中对象的动画，并记录这些卡被选为对象。
			Duel.HintSelection(sg)
			-- 将选择的怪兽变成里侧守备表示。
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end
	end
end

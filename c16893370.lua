--夢現の寝姫－ネムレリア・レアリゼ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合，可以从以下效果选择1个发动。
-- ●从卡组把1只「梦见之妮穆蕾莉娅」表侧加入额外卡组。
-- ●场上1只其他的表侧表示怪兽变成里侧守备表示。
-- ③：这张卡的攻击力上升自己的额外卡组的里侧的卡数量×100。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：攻击力提升、手牌发动效果、特殊召唤后触发效果
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
-- 计算额外卡组中里侧表示的卡的数量并乘以100作为攻击力加成
function s.atkval(e,c)
	-- 返回额外卡组中里侧表示的卡的数量乘以100
	return Duel.GetMatchingGroupCount(Card.IsFacedown,c:GetControler(),LOCATION_EXTRA,0,nil)*100
end
-- 过滤函数，判断目标怪兽是否可以送回卡组且场上存在可用怪兽区
function s.filter(c,tp)
	-- 返回场上存在可用怪兽区且目标怪兽可以送回卡组
	return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToDeck()
end
-- 设置①效果的发动条件和目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数，将目标怪兽送回卡组并特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否有效且已成功送回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 检查是否有足够的怪兽区且自身有效
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于选择可加入额外卡组的「梦见之妮穆蕾莉娅」灵摆卡
function s.edfilter(c)
	return c:IsCode(70155677) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 过滤函数，用于选择可变为里侧守备表示的场上表侧表示怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的目标选择函数，根据可选效果设置选项并选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中符合条件的「梦见之妮穆蕾莉娅」灵摆卡
	local g1=Duel.GetMatchingGroup(s.edfilter,tp,LOCATION_DECK,0,nil)
	-- 获取场上符合条件的表侧表示怪兽
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
	-- 让玩家选择要发动的效果
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_TOEXTRA)
		-- 设置操作信息：将卡加入额外卡组
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
	elseif sel==1 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
		-- 设置操作信息：将怪兽变为里侧守备表示
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g2,1,0,0)
	end
end
-- ②效果的处理函数，根据选择的效果执行相应操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 提示玩家选择要加入额外卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 选择要加入额外卡组的卡
		local g=Duel.SelectMatchingCard(tp,s.edfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡加入额外卡组
			Duel.SendtoExtraP(g,nil,REASON_EFFECT)
		end
	elseif sel==1 then
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择要变为里侧守备表示的怪兽
		local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e))
		if #sg>0 then
			-- 显示选中的怪兽被选为对象的动画
			Duel.HintSelection(sg)
			-- 将选中的怪兽变为里侧守备表示
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end
	end
end

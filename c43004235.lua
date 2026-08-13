--海造賊－祝宴
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：自己场上有「海造贼」怪兽存在的场合才能把这张卡发动。自己从卡组抽出自己场上的装备卡的数量＋1张，那之后手卡选自己场上的装备卡的数量回到卡组。
-- ②：这张卡在墓地存在，自己从额外卡组把「海造贼」怪兽特殊召唤的场合才能发动。这张卡给那1只怪兽当作攻击力上升500的装备卡使用来装备。
function c43004235.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「海造贼」怪兽存在的场合才能把这张卡发动。自己从卡组抽出自己场上的装备卡的数量＋1张，那之后手卡选自己场上的装备卡的数量回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43004235,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43004235)
	e1:SetCondition(c43004235.condition)
	e1:SetTarget(c43004235.target)
	e1:SetOperation(c43004235.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果在决斗中只能使用1次。②：这张卡在墓地存在，自己从额外卡组把「海造贼」怪兽特殊召唤的场合才能发动。这张卡给那1只怪兽当作攻击力上升500的装备卡使用来装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43004235,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_EQUIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,43004236+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c43004235.eqcon)
	e2:SetTarget(c43004235.eqtg)
	e2:SetOperation(c43004235.eqop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为表侧表示且属于「海造贼」字段，用于检查自己场上是否存在符合条件的「海造贼」怪兽。
function c43004235.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- ①的发动条件判定：当自己场上存在表侧表示的海造贼怪兽时，该卡可以发动。
function c43004235.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1张表侧表示且字段为「海造贼」的怪兽。
	return Duel.IsExistingMatchingCard(c43004235.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：统计场上表侧表示或被装备中的装备魔法卡数量（作为装备卡计数的判定条件）。
function c43004235.drfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP)
end
-- ①的发动时处理：统计场上装备卡数量i；确认可抽i+1张后，将对象玩家设为自己、抽卡张数设为i+1、回卡组张数设为i，并写入抽卡与回卡组的操作信息。
function c43004235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己场上的装备魔法卡数量（表侧表示或被装备中的装备卡），作为抽卡张数（i+1）和回卡组张数（i）的计算基准。
	local i=Duel.GetMatchingGroupCount(c43004235.drfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 发动时合法性检查：若自己不能抽i+1张卡，则此卡不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,i+1) end
	-- 将当前连锁的对象玩家设置为自己，使后续处理以自己为抽卡/回卡组的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为抽卡张数（i+1），供效果处理时获取。
	Duel.SetTargetParam(i+1)
	-- 写入抽卡操作信息：对象玩家为自己，抽卡数量为i+1，用于效果发动/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,i+1)
	-- 写入回卡组操作信息：对象玩家为自己，回卡组数量为i，用于效果发动/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,i)
end
-- ①的解决时：让对象玩家抽i+1张卡；若抽卡数为0则结束；若i>0，则洗切手牌、中断效果时点，然后从手卡选择i张卡返回持有者卡组并洗切卡组。
function c43004235.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时记录的对象玩家（自己），作为抽卡和回卡组的执行玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 按对象玩家视角重新统计场上的装备魔法卡数量，用于确定回卡组的手卡数量。
	local i=Duel.GetMatchingGroupCount(c43004235.drfilter,p,LOCATION_ONFIELD,0,nil)
	-- 让对象玩家抽i+1张卡；若实际抽取数量为0，则不再进行后续回卡组处理。
	if Duel.Draw(p,i+1,REASON_EFFECT)==0 then return end
	if i>0 then
		-- 洗切对象玩家的手牌，确保手牌顺序随机后返回卡组。
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续的回卡组处理与抽卡处理分开时点（对应原文的'那之后'）。
		Duel.BreakEffect()
		-- 向玩家显示「请选择要返回卡组的卡」的提示信息，并缓存选择用提示文本。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从对象玩家的手卡中选择i张可以返回卡组的卡，选择数量等于场上的装备卡数量。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,i,i,nil)
		if g:GetCount()>0 then
			-- 将选中的手卡返回持有者卡组并洗切卡组，回卡组原因为效果。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 过滤函数：判断怪兽是否为由tp从额外卡组特殊召唤的表侧表示「海造贼」怪兽，用于②效果的诱发判定。
function c43004235.exfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(tp) and c:IsSetCard(0x13f) and c:IsFaceup()
end
-- ②的诱发条件：当特殊召唤成功的怪兽中存在由自己从额外卡组特殊召唤的表侧表示「海造贼」怪兽时，此效果才满足发动条件。
function c43004235.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43004235.exfilter,1,nil,tp)
end
-- 过滤函数：判断候选怪兽c是否属于刚刚特殊召唤成功的「海造贼」怪兽集合g，用于从中选择装备对象。
function c43004235.eqfilter(c,g)
	return g:IsContains(c)
end
-- ②发动时检查：确认自己魔陷区有空位、此卡可装备，且场上存在刚特殊召唤的「海造贼」怪兽作为装备对象；满足时发动合法。
function c43004235.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(c43004235.exfilter,nil,tp)
	-- ②发动时的条件之一：自己魔陷区有空位，且此卡未被禁止作为装备卡使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
		-- ②发动时的条件之一：确认双方怪兽区存在至少1只刚特殊召唤成功的「海造贼」怪兽，可供此卡装备。
		and Duel.IsExistingMatchingCard(c43004235.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	-- 在发动确定执行时，写入此卡将离开墓地的操作信息（用于「王家长眠之谷」等墓地效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②的解决时：再次确认魔陷区空位且此卡可装备；从本次特殊召唤成功的「海造贼」怪兽中选择1只，成功装备后给该怪兽附加攻击力上升500的效果，并设置只能装备给该怪兽的限制。
function c43004235.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己魔陷区没有空位，则无法将这张卡装备，效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	if not c:IsRelateToEffect(e) or c:IsForbidden() or not c:CheckUniqueOnField(tp,LOCATION_SZONE) then return end
	local g=eg:Filter(c43004235.exfilter,nil,tp)
	-- 显示「请选择表侧表示的卡」的提示信息，并准备选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方怪兽区选择1只本次特殊召唤成功的「海造贼」怪兽作为装备对象。
	local sg=Duel.SelectMatchingCard(tp,c43004235.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	local tc=sg:GetFirst()
	if tc then
		-- 将选中的怪兽显示为被选择对象，并记录其与当前连锁的关联。
		Duel.HintSelection(sg)
		-- 执行装备：将这张卡装备给tc；装备成功后才继续附加效果和限制。
		if Duel.Equip(tp,c,tc) then
			-- 这张卡给那1只怪兽当作攻击力上升500的装备卡使用来装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(tc)
			e1:SetValue(c43004235.eqlimit)
			c:RegisterEffect(e1)
			-- 攻击力上升500。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(500)
			c:RegisterEffect(e2)
		end
	end
end
-- 装备限制判定：仅当装备对象是记录中的目标怪兽（LabelObject）时，此装备卡才允许装备。
function c43004235.eqlimit(e,c)
	return c==e:GetLabelObject()
end

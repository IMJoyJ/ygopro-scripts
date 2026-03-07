--迷宮の重魔戦車
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡在召唤的回合不能攻击。
-- ③：自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。自己场上有「迷宫壁」卡存在的场合，可以再把对方场上1只怪兽破坏。
function c35026117.initial_effect(c)
	-- 记录该卡牌可以召唤的额外怪兽卡的卡号
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- ①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35026117,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c35026117.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c35026117.atklimit)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。自己场上有「迷宫壁」卡存在的场合，可以再把对方场上1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35026117,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,35026117)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c35026117.tftg)
	e3:SetOperation(c35026117.tfop)
	c:RegisterEffect(e3)
end
-- 判断是否满足不需解放的召唤条件
function c35026117.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足不需解放召唤的条件：不需解放、等级5以上、场上存在召唤位置
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 设置召唤成功后的攻击限制效果
function c35026117.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 使该卡在召唤成功后不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 筛选可作为永续魔法卡使用的魔神卡
function c35026117.tffilter(c,tp)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 判断是否满足发动条件：场上存在魔法陷阱区域且有符合条件的魔神卡
function c35026117.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否在手牌、卡组或除外区存在符合条件的魔神卡
		and Duel.IsExistingMatchingCard(c35026117.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,nil,tp) end
end
-- 筛选场上的迷宫壁卡
function c35026117.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x193)
end
-- 执行效果处理：选择魔神卡并放置为永续魔法卡，若满足条件则破坏对方怪兽
function c35026117.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择符合条件的魔神卡
	local g=Duel.SelectMatchingCard(tp,c35026117.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 将选中的卡移动到魔法陷阱区域
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将选中的卡转换为永续魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		-- 判断对方场上是否存在怪兽
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
			-- 判断己方场上是否存在迷宫壁卡
			and Duel.IsExistingMatchingCard(c35026117.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 询问玩家是否选择破坏对方怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(35026117,2)) then  --"是否选对方场上1只怪兽破坏？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择对方场上的1只怪兽
			local tg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
			-- 显示被选中的怪兽
			Duel.HintSelection(tg)
			-- 破坏选中的怪兽
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end

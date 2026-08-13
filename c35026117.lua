--迷宮の重魔戦車
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡在召唤的回合不能攻击。
-- ③：自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。自己场上有「迷宫壁」卡存在的场合，可以再把对方场上1只怪兽破坏。
function c35026117.initial_effect(c)
	-- 将这张卡的效果文本中提到的三张魔神卡（雷魔神-桑迦、风魔神-修迦、水魔神-斯迦）登记为这张卡的关联卡号，使系统能识别这些记载的卡名。
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
-- 该条件函数用于判定‘可以不用解放作召唤’是否可用：当通常召唤所需解放数为0（即不解放）、这张卡等级不低于5且我方主要怪兽区有空位时，才允许进行无解放召唤。
function c35026117.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断本次通常召唤是否满足无解放召唤的条件：召唤所需解放数为0、此卡等级不低于5、且我方主要怪兽区域有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 这是召唤成功时触发的效果操作：为这张卡自身附加‘不能攻击’的效果，该效果持续到结束阶段或卡片离开场上等重置时机。
function c35026117.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡在召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 该过滤器用于选择可从手卡·卡组·除外状态中选择的魔神卡：必须是三张指定魔神之一，不是被禁止的卡，且己方场上不存在同名卡。
function c35026117.tffilter(c,tp)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ③效果的发动合法性检查：己方魔法与陷阱区域有空位，且手卡·卡组·除外状态中存在至少一张符合条件的魔神卡时，效果才能发动。
function c35026117.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查己方魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认手卡·卡组·除外状态中是否存在至少一张符合条件的魔神卡（三种魔神中任意一张）。
		and Duel.IsExistingMatchingCard(c35026117.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,nil,tp) end
end
-- 该过滤器检查卡片是否为表侧表示且属于「迷宫壁」系列（卡片编号0x193），用于判断己方场上是否存在「迷宫壁」卡。
function c35026117.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x193)
end
-- ③效果处理：从手卡·卡组·除外状态中选择1只符合条件的魔神卡，以表侧表示放置在己方魔法与陷阱区域，并将其变为永续魔法卡；之后若己方场上存在「迷宫壁」卡且对方场上有怪兽，则询问玩家是否选择对方场上1只怪兽破坏，若同意则破坏那只怪兽。
function c35026117.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方魔法与陷阱区域没有空位，则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 给玩家显示选择提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家从手卡·卡组·除外状态中选择1张符合条件的魔神卡（该选择在效果处理时进行，不构成取对象）。
	local g=Duel.SelectMatchingCard(tp,c35026117.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 将选中的魔神卡当作永续魔法卡以表侧表示放置到己方的魔法与陷阱区域。
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		-- 检查对方怪兽区域是否存在至少1只怪兽。
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
			-- 确认己方场上是否存在表侧表示的「迷宫壁」卡。
			and Duel.IsExistingMatchingCard(c35026117.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 询问玩家是否选择对方场上1只怪兽破坏，玩家选择‘是’时才执行后续破坏处理。
			and Duel.SelectYesNo(tp,aux.Stringid(35026117,2)) then  --"是否选对方场上1只怪兽破坏？"
			-- 中断当前效果，使后续的追加破坏处理作为单独的动作进行，避免错过时点。
			Duel.BreakEffect()
			-- 给玩家显示选择提示：请选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择对方怪兽区域的1只怪兽（不限定表示形式）作为破坏对象。
			local tg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
			-- 为所选择的破坏对象播放选中动画，并记录这张卡成为效果处理的对象。
			Duel.HintSelection(tg)
			-- 以效果破坏所选择的怪兽。
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end

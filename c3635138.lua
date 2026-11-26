--冥府よりの使者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己受到战斗·效果伤害的场合才能发动。这张卡从手卡特殊召唤，自己回复2000基本分。那之后，可以从以下效果选1个适用。
-- ●从自己的手卡·卡组·墓地把1只「来自冥府的使者」特殊召唤。
-- ●对方场上最多2只攻击表示怪兽破坏。
-- ②：这张卡特殊召唤的回合的结束阶段，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化「来自冥府的使者」(3635138)：注册①受伤害从手卡特召并回血及二选一追加效果、特殊召唤回合标记效果以及②结束阶段盖放墓地陷阱卡效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己受到战斗·效果伤害的场合才能发动。这张卡从手卡特殊召唤，自己回复2000基本分。那之后，可以从以下效果选1个适用。●从自己的手卡·卡组·墓地把1只「来自冥府的使者」特殊召唤。●对方场上最多2只攻击表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的回合的结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放陷阱"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 效果①的Condition函数：检查受到伤害的玩家是否为己方(tp)，且伤害原因为战斗或效果伤害
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果①的Target函数：检测己方怪兽区有空位且这张卡可特召，并设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方主要怪兽区至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡中的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：筛选卡组·手卡·墓地中可被特殊召唤的「来自冥府的使者」(id)
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Operation函数：特召这张卡并回复2000基本分后，刷新场地并让玩家从“特召同名卡”、“破坏对方最多2只攻击表示怪兽”或“都不适用”中选择1个执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁关联，将其从手卡表侧特殊召唤到己方场上后使己方回复2000基本分
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Recover(tp,2000,REASON_EFFECT)~=0 then
		-- 立刻刷新场地状态，使接下来的可选效果判定基于最新场面
		Duel.AdjustAll()
		-- 检测己方主要怪兽区是否还有可用空位（用于判定选项1是否可执行）
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测己方卡组·手卡·墓地中是否存在不受「王家长眠之谷」限制且可特召的「来自冥府的使者」
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检测对方怪兽区是否存在至少1只表侧攻击表示的怪兽（用于判定选项2是否可执行）
		local b2=Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
		-- 弹出选项让玩家从“特召同名卡”、“破坏对方攻击表示怪兽”或“什么都不做”中选择
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2)},  --"特殊召唤"
			{b2,aux.Stringid(id,3)},  --"破坏效果"
			{true,aux.Stringid(id,4)})  --"什么都不做"
		if op==1 then
			-- 中断当前处理步骤，使后续同名卡的特殊召唤视为不同时处理（“那之后”）
			Duel.BreakEffect()
			-- 向己方玩家发送选择要特殊召唤的「来自冥府的使者」提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从己方卡组·手卡·墓地中选择1只不受「王家长眠之谷」限制的「来自冥府的使者」
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的「来自冥府的使者」以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			-- 中断当前处理步骤，使后续破坏对方怪兽的处理视为不同时处理（“那之后”）
			Duel.BreakEffect()
			-- 向己方玩家发送选择要破坏的对方怪兽提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 从对方场上选择1至2只表侧攻击表示的怪兽
			local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,2,nil,POS_FACEUP_ATTACK)
			-- 手动为选中的对方攻击表示怪兽显示被选定提示动画
			Duel.HintSelection(g)
			-- 以效果破坏选中的对方攻击表示怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 特殊召唤标记效果的Operation函数：在这张卡特殊召唤成功时注册持续至本回合结束阶段的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的Condition函数：检查场上的这张卡是否带有本回合特殊召唤成功的标记
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 过滤函数：筛选墓地中可以盖放到己方魔陷区的陷阱卡
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的Target函数：取己方墓地1张可盖放的陷阱卡为对象，并设置离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 发动检测时确认己方墓地存在至少1张可以作为对象盖放的陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向己方玩家发送选择要盖放的陷阱卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从己方墓地选择1张可盖放的陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将所选陷阱卡离开墓地（盖放）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的Operation函数：确认对象陷阱卡仍与当前连锁关联且不受「王家长眠之谷」影响后，将其盖放到己方场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果时指定为对象的那1张陷阱卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象陷阱卡是否仍与当前连锁关联且未受到「王家长眠之谷」效果的无效化干扰
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的对象陷阱卡盖放到己方魔法与陷阱区域
		Duel.SSet(tp,tc)
	end
end

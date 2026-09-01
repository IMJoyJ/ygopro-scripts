--冥府よりの使者
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己受到战斗·效果伤害的场合才能发动。这张卡从手卡特殊召唤，自己回复2000基本分。那之后，可以从以下效果选择1个适用。●从自己的手卡·卡组·墓地把1只「冥府之使者」特殊召唤。●选对方场上最多2只攻击表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 记录特殊召唤成功的事实
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ③：这张卡特殊召唤的回合的结束阶段，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
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
-- ①效果的发动条件：自己受到战斗或效果伤害
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ①效果的目标：检查怪兽区空位并特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤同名卡
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理：特殊召唤自身、回复LP并选择后续处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤自身并回复2000LP
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Recover(tp,2000,REASON_EFFECT)~=0 then
		-- 刷新场地信息
		Duel.AdjustAll()
		-- 检查怪兽区是否有空位特招同名卡
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在同名卡
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查对方场上是否存在攻击表示怪兽
		local b2=Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
		-- 玩家选择后续处理分支
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)},
			{true,aux.Stringid(id,4)})
		if op==1 then
			-- 动作连接，前后效果不同时处理
			Duel.BreakEffect()
			-- 提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手牌·卡组·墓地选择1只同名卡
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将同名卡特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			-- 动作连接，前后效果不同时处理
			Duel.BreakEffect()
			-- 提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择对方场上1到2只攻击表示怪兽
			local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,2,nil,POS_FACEUP_ATTACK)
			-- 显示选中的怪兽
			Duel.HintSelection(g)
			-- 破坏选中的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 注册本回合特殊召唤成功的标识
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③效果的发动条件：本回合特殊召唤过
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 过滤可以盖放的陷阱卡
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的目标：选择墓地1张陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查墓地是否存在可盖放的陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择墓地1张陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的处理：将墓地的目标陷阱卡在场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标陷阱卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标陷阱卡是否仍存在且不受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标陷阱卡在场上盖放
		Duel.SSet(tp,tc)
	end
end

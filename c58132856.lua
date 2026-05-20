--トイ・マジシャン
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。自己的魔法与陷阱卡区域盖放的这张卡被对方的卡的效果破坏送去墓地的场合，那个回合的结束阶段时这张卡从墓地特殊召唤。此外，这张卡反转召唤成功时，把场上表侧表示存在的「玩具魔术师」的数量的场上存在的魔法·陷阱卡破坏。
function c58132856.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 自己的魔法与陷阱卡区域盖放的这张卡被对方的卡的效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c58132856.regop)
	c:RegisterEffect(e2)
	-- 那个回合的结束阶段时这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58132856,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(c58132856.sptg)
	e3:SetOperation(c58132856.spop)
	c:RegisterEffect(e3)
	-- 此外，这张卡反转召唤成功时，把场上表侧表示存在的「玩具魔术师」的数量的场上存在的魔法·陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(58132856,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e4:SetTarget(c58132856.destg)
	e4:SetOperation(c58132856.desop)
	c:RegisterEffect(e4)
end
c58132856.set_as_spell=true
-- 检查被送去墓地的这张卡是否原本在自己的魔陷区盖放、且因对方的效果破坏，若是则注册一个在回合结束时重置的Flag
function c58132856.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and rp==1-tp then
		c:RegisterFlagEffect(58132856,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
-- 结束阶段特殊召唤效果的启动检测与效果处理准备，检查是否注册了对应的Flag，并设置特殊召唤的操作信息
function c58132856.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(58132856)>0 end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 结束阶段特殊召唤效果的实际处理，若自身仍在墓地则将其特殊召唤
function c58132856.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示存在的「玩具魔术师」
function c58132856.cfilter(c)
	return c:IsFaceup() and c:IsCode(58132856)
end
-- 过滤条件：场上的魔法·陷阱卡
function c58132856.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 反转召唤成功时破坏效果的启动检测与效果处理准备，计算场上表侧表示的「玩具魔术师」数量与场上魔陷数量，并设置破坏的操作信息
function c58132856.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上表侧表示存在的「玩具魔术师」的数量
	local ct=Duel.GetMatchingGroupCount(c58132856.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 获取双方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c58132856.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct>g:GetCount() then ct=g:GetCount() end
	-- 设置当前连锁的操作信息为：破坏指定数量的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 反转召唤成功时破坏效果的实际处理，让玩家选择与场上表侧表示「玩具魔术师」数量相同的魔法·陷阱卡并破坏
function c58132856.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前双方场上表侧表示存在的「玩具魔术师」的数量
	local ct=Duel.GetMatchingGroupCount(c58132856.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct==0 then return end
	-- 给发动效果的玩家发送“选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择与「玩具魔术师」数量相同的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c58132856.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 为选中的卡片显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 因效果破坏选中的魔法·陷阱卡
	Duel.Destroy(g,REASON_EFFECT)
end

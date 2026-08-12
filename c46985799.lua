--ブラック・ローズ・ドラゴン／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这张卡回到卡组，场上1只怪兽的攻击力变成0。
-- ②：这张卡特殊召唤的场合或者对方场上有怪兽特殊召唤的场合才能发动。场上的卡全部破坏。
-- ③：这张卡被破坏的场合才能发动。从自己墓地把1只「黑蔷薇龙」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 记录卡片关联密码「黑蔷薇龙」与「爆裂模式」
	aux.AddCodeList(c,73580471,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤限制为「爆裂模式」
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 把手卡的这张卡给对方观看才能发动。这张卡回到卡组，场上1只怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"攻击力改变"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤的场合或者对方场上有怪兽特殊召唤的场合才能发动。场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
	-- 这张卡被破坏的场合才能发动。从自己墓地把1只「黑蔷薇龙」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.assault_name=73580471
-- 展示手牌的这张卡作为发动代价
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end

-- 过滤场上表侧表示且攻击力不为0的怪兽
function s.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(0)
end
-- 回到卡组并改变攻击力效果的发动检测与操作整理
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检测场上是否存在符合条件的怪兽且自身能否回到卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and c:IsAbleToDeck() end
	-- 设置将自身送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 回到卡组并改变攻击力效果的具体处理
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果自身没能成功送回卡组则不处理后续效果
	if not (c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK)) then return end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示攻击力不为0的怪兽
	local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 对选中的怪兽显示选择动画
		Duel.HintSelection(g)
		-- 场上1只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 触发条件：对方场上有怪兽特殊召唤的场合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 破坏效果的发动检测与操作整理
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否存在可以破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏场上全部卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的具体处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将场上的所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 特殊召唤「黑蔷薇龙」效果的发动检测与操作整理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测怪兽区是否有空位且墓地是否存在可以特殊召唤的「黑蔷薇龙」
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤墓地怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤墓地中的「黑蔷薇龙」
function s.spfilter(c,e,tp)
	return c:IsCode(73580471) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤「黑蔷薇龙」效果的具体处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只「黑蔷薇龙」并应用王家长眠之谷的过滤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

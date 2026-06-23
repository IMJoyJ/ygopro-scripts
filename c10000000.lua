--オベリスクの巨神兵
-- 效果：
-- 这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
-- ③：双方不能把场上的这张卡作为效果的对象。
-- ④：把自己场上2只怪兽解放才能发动（这个效果发动的回合，这张卡不能攻击宣言）。对方场上的怪兽全部破坏。
-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
function c10000000.initial_effect(c)
	-- 创建效果，设置描述为“把3只解放作召唤”，属性为不能无效和不可复制，类型为单次效果，代码为召唤限制过程，条件为c10000000.ttcon函数，操作为c10000000.ttop函数，值为上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000000,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000000.ttcon)
	e1:SetOperation(c10000000.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 创建效果，设置类型为单次效果，代码为放置规则限制，条件为c10000000.setcon函数。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000000.setcon)
	c:RegisterEffect(e2)
	-- 创建效果，设置类型为单次效果，代码为不能无效召唤，属性为不能无效和不可复制。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 创建效果，设置类型为单次+连续效果，代码为召唤成功事件，操作为c10000000.sumsuc函数。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000000.sumsuc)
	c:RegisterEffect(e4)
	-- 创建效果，设置类型为单次效果，代码为不能成为效果对象，属性为单卡范围，作用区域为主怪兽区，值为1。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- 创建效果，设置描述为“送去墓地”，分类为送去墓地效果，类型为场地+诱发必发效果，作用区域为主怪兽区，连锁限制次数为1，代码为阶段结束事件，条件为c10000000.tgcon函数，目标为c10000000.tgtg函数，操作为c10000000.tgop函数。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(10000000,0))  --"送去墓地"
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCondition(c10000000.tgcon)
	e6:SetTarget(c10000000.tgtg)
	e6:SetOperation(c10000000.tgop)
	c:RegisterEffect(e6)
	-- 创建效果，设置描述为“对方怪兽全部破坏”，分类为破坏效果，类型为点火效果，作用区域为主怪兽区，代价为c10000000.descost函数，目标为c10000000.destg函数，操作为c10000000.desop函数。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(10000000,1))  --"对方怪兽全部破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCost(c10000000.descost)
	e7:SetTarget(c10000000.destg)
	e7:SetOperation(c10000000.desop)
	c:RegisterEffect(e7)
end
-- 定义条件函数c10000000.ttcon，判断是否满足通常召唤的解放数量要求。
function c10000000.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断解放数量小于等于3并且存在用于通常召唤的3只怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 定义操作函数c10000000.ttop，选择用于通常召唤的祭品并进行解放。
function c10000000.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3-3张怪兽作为祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 以REASON_SUMMON和REASON_MATERIAL原因解放选定的祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义条件函数c10000000.setcon，返回false表示不限制放置。
function c10000000.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 定义操作函数c10000000.sumsuc，设置连锁直到结束。
function c10000000.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁直到结束，禁止发动效果。
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 定义条件函数c10000000.tgcon，判断是否为特殊召唤。
function c10000000.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 定义目标选择函数c10000000.tgtg，设置操作信息为送去墓地。
function c10000000.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，类别为送去墓地，目标为自身卡片，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 定义操作函数c10000000.tgop，将场上的这张卡送去墓地。
function c10000000.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以REASON_EFFECT原因将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 定义代价函数c10000000.descost，检查是否可以解放怪兽并进行解放。
function c10000000.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断攻击宣言数量为0并且存在至少2只可解放的怪兽。
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 and Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 创建效果，设置类型为单次效果，属性为誓约，代码为不能攻击宣言，重置条件为事件+标准重置+阶段结束。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	-- 让玩家选择2-2张怪兽作为解放素材。
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 以REASON_COST原因解放选定的怪兽。
	Duel.Release(g,REASON_COST)
end
-- 定义目标选择函数c10000000.destg，检查场上是否存在可破坏的怪兽。
function c10000000.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在至少1张怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取场上的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息，类别为破坏效果，目标为所有怪兽，数量为怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义操作函数c10000000.desop，破坏场上所有怪兽。
function c10000000.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以REASON_EFFECT原因破坏选定的怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end

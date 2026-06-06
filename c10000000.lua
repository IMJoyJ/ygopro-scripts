--オベリスクの巨神兵
-- 效果：
-- 这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
-- ③：双方不能把场上的这张卡作为效果的对象。
-- ④：把自己场上2只怪兽解放才能发动（这个效果发动的回合，这张卡不能攻击宣言）。对方场上的怪兽全部破坏。
-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
function c10000000.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000000,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000000.ttcon)
	e1:SetOperation(c10000000.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000000.setcon)
	c:RegisterEffect(e2)
	-- ①：这张卡的召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- ②：在这张卡的召唤成功时双方不能把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000000.sumsuc)
	c:RegisterEffect(e4)
	-- ③：双方不能把场上的这张卡作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ⑤：这张卡特殊召唤的场合，结束阶段发动。这张卡送去墓地。
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
	-- ④：把自己场上2只怪兽解放才能发动（这个效果发动的回合，这张卡不能攻击宣言）。对方场上的怪兽全部破坏。
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
-- 召唤条件判断：检查是否满足3只解放的要求，且场上有3个可用于召唤的祭品
function c10000000.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查玩家是否能提供3只解放作召唤
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 召唤操作的执行：选择3只祭品解放，并为该卡设置解放素材
function c10000000.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3只用于通常召唤该卡的解放怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选取的怪兽
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 放置条件限制：直接返回false，使得此卡不能被里侧表示放置
function c10000000.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 召唤成功时的处理：在召唤成功时设置连锁限制，阻止任何卡的效果发动
function c10000000.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁条件限制为不能发动效果
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
-- 送去墓地效果的发动条件：判断此卡是否为特殊召唤
function c10000000.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 送去墓地效果的目标确定：设置操作信息为将该卡送去墓地
function c10000000.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果的操作信息为将自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 送去墓地效果的执行：如果此卡在场上表侧表示存在，则将其送去墓地
function c10000000.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 破坏效果代价的处理：检查发动条件并进行解放代价支付，同时注册此回合不能进行攻击宣言的效果
function c10000000.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付解放2只怪兽的代价，且此卡在当前回合尚未宣言过攻击
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 and Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 给自身注册本回合不能宣言攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	-- 选择自己场上2只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 解放所选择的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 破坏效果的目标确定：检查并获取对方场上的所有怪兽以确定为破坏对象
function c10000000.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的全部怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏对方场上的全部怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行：获取并破坏对方场上的所有怪兽
function c10000000.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上的全部怪兽
	Duel.Destroy(g,REASON_EFFECT)
end

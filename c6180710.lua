--ドリーム・シャーク
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有水属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡1回合只有1次不会被战斗破坏。
-- ③：这张卡在墓地存在，给与自己伤害的效果发动时才能发动。这张卡特殊召唤，那个效果让自己受到的伤害变成0。这个效果特殊召唤的这张卡守备力下降1000，从场上离开的场合除外。
function c6180710.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有水属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6180710,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,6180710)
	e1:SetCondition(c6180710.spcon)
	e1:SetTarget(c6180710.sptg)
	e1:SetOperation(c6180710.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c6180710.valcon)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，给与自己伤害的效果发动时才能发动。这张卡特殊召唤，那个效果让自己受到的伤害变成0。这个效果特殊召唤的这张卡守备力下降1000，从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6180710,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,6180711)
	-- 设置效果的发动条件为给与自己伤害的效果发动时
	e3:SetCondition(aux.damcon1)
	e3:SetTarget(c6180710.sptg2)
	e3:SetOperation(c6180710.spop2)
	c:RegisterEffect(e3)
end
-- 过滤场上里侧表示怪兽或非水属性怪兽的辅助函数
function c6180710.cfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果1的发动条件：自己场上不存在里侧表示怪兽和非水属性怪兽
function c6180710.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在里侧表示怪兽和非水属性怪兽
	return not Duel.IsExistingMatchingCard(c6180710.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果1的发动准备与合法性检查
function c6180710.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的效果处理：将自身特殊召唤
function c6180710.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置不会被破坏的抗性仅适用于战斗破坏
function c6180710.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 效果3的发动准备与合法性检查
function c6180710.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果3的效果处理：特殊召唤自身，使伤害变0，并适用守备力下降和离场除外的效果
function c6180710.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍存在于墓地且成功特殊召唤上场
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取触发该效果的连锁的唯一标识ID
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 那个效果让自己受到的伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c6180710.damval)
		e1:SetReset(RESET_CHAIN)
		-- 注册使该连锁伤害变成0的全局效果
		Duel.RegisterEffect(e1,tp)
		-- 从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 这个效果特殊召唤的这张卡守备力下降1000
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e3:SetValue(-1000)
		c:RegisterEffect(e3)
	end
end
-- 伤害改变效果的数值计算函数：若为对应连锁的效果伤害，则将伤害数值变为0
function c6180710.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前正在处理的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end

--宇宙獣ガンギル
-- 效果：
-- 把自己场上存在的原本持有者是对方的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。1回合1次，可以在对方场上1只怪兽放置1个A指示物。放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
function c51192573.initial_effect(c)
	-- 效果原文：把自己场上存在的原本持有者是对方的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51192573,0))  --"用1只祭品作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c51192573.otcon)
	e1:SetOperation(c51192573.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 效果原文：1回合1次，可以在对方场上1只怪兽放置1个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51192573,1))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c51192573.cttg)
	e2:SetOperation(c51192573.ctop)
	c:RegisterEffect(e2)
	-- 效果原文：放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c51192573.adcon)
	e3:SetTarget(c51192573.adtg)
	e3:SetValue(c51192573.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
c51192573.counter_add_list={0x100e}
-- 过滤函数：判断卡的持有者是否为指定玩家。
function c51192573.otfilter(c,tp)
	return c:GetOwner()==tp
end
-- 召唤条件函数：检查是否满足使用对方怪兽作为祭品进行上级召唤的条件。
function c51192573.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有属于对方的怪兽作为可能的祭品。
	local mg=Duel.GetMatchingGroup(c51192573.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 返回值：当前卡片等级不低于7，所需祭品数量不超过1，并且可以找到满足条件的祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 召唤操作函数：选择并解放符合条件的祭品怪兽完成召唤。
function c51192573.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有属于对方的怪兽作为可能的祭品。
	local mg=Duel.GetMatchingGroup(c51192573.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 从指定位置选择一个祭品怪兽。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品怪兽解放，用于召唤。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 放置A指示物的效果目标选择函数：选择对方场上的一个可以添加A指示物的怪兽。
function c51192573.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 检查是否有满足条件的目标怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个可以添加A指示物的目标怪兽。
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置操作信息，表明本次效果将为目标怪兽放置1个A指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 放置A指示物的效果执行函数：为选中的目标怪兽添加1个A指示物。
function c51192573.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
-- 伤害计算阶段触发条件函数：判断是否处于伤害计算阶段且存在攻击对象。
function c51192573.adcon(e)
	-- 返回值：当前阶段为伤害计算阶段，并且存在攻击目标。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 攻击力变化效果的目标筛选函数：判断目标怪兽是否具有A指示物并且攻击对象属于「外星」系列。
function c51192573.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 攻击力变化效果的数值计算函数：根据A指示物数量计算攻击力下降值。
function c51192573.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

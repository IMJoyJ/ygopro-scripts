--宇宙獣ガンギル
-- 效果：
-- 把自己场上存在的原本持有者是对方的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。1回合1次，可以在对方场上1只怪兽放置1个A指示物。放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
function c51192573.initial_effect(c)
	-- 把原本持有者是对方的怪兽作为祭品时，可以用1只祭品作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51192573,0))  --"用1只祭品作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c51192573.otcon)
	e1:SetOperation(c51192573.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以在对方场上1只怪兽放置1个A指示物
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
	-- 放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300
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
c51192573.mentioned_counter={
	[0x100e]=true,
}
-- 用于判断怪兽是否为对方控制的过滤函数
function c51192573.otfilter(c,tp)
	return c:GetOwner()==tp
end
-- 判断是否满足用1只祭品作召唤的条件
function c51192573.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上的所有怪兽作为可能的祭品
	local mg=Duel.GetMatchingGroup(c51192573.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 检查是否有足够的祭品进行通常召唤
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只祭品作召唤的操作
function c51192573.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方场上的所有怪兽作为可能的祭品
	local mg=Duel.GetMatchingGroup(c51192573.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 选择用于通常召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品解放用于召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 设置放置A指示物效果的目标选择逻辑
function c51192573.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 检查是否存在可以放置A指示物的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择放置A指示物的目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置操作信息，记录将要放置的A指示物数量
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 执行放置A指示物的操作
function c51192573.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
-- 判断是否处于伤害计算阶段且存在攻击对象
function c51192573.adcon(e)
	-- 检查当前阶段是否为伤害计算时并且有攻击目标
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 设定攻击力下降效果的适用条件
function c51192573.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算因A指示物导致的攻击力下降值
function c51192573.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

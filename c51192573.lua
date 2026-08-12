--宇宙獣ガンギル
-- 效果：
-- 把自己场上存在的原本持有者是对方的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。1回合1次，可以在对方场上1只怪兽放置1个A指示物。放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
function c51192573.initial_effect(c)
	-- 把自己场上存在的原本持有者是对方的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51192573,0))  --"用1只祭品作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c51192573.otcon)
	e1:SetOperation(c51192573.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以在对方场上1只怪兽放置1个A指示物。
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
	-- 放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
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
-- 过滤函数：判断卡片的原本持有者是否为指定玩家（用于找出原本持有者是对方的怪兽）。
function c51192573.otfilter(c,tp)
	return c:GetOwner()==tp
end
-- 上级召唤的召唤条件：检索双方场上原本持有者是对方的怪兽，确认这张卡是7星以上且可以用其中1只作为祭品进行召唤。
function c51192573.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索双方场上原本持有者是对方的怪兽，作为可用祭品的候选卡组。
	local mg=Duel.GetMatchingGroup(c51192573.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 确认这张卡等级在7以上、所需祭品数不超过1，且场上存在可用作祭品的原本持有者是对方的怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤的召唤处理：让玩家从原本持有者是对方的怪兽中选择1只作为祭品，将其作为召唤素材解放。
function c51192573.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 检索双方场上原本持有者是对方的怪兽，作为可选祭品的范围。
	local mg=Duel.GetMatchingGroup(c51192573.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 让玩家从这些怪兽中选择1只作为这张卡上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤·素材的原因解放选作祭品的怪兽。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 放置A指示物效果的对象选择：确认对方场上存在可以放置A指示物的怪兽，并选择其中1只作为效果对象。
function c51192573.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 发动条件检测：确认对方场上存在至少1只可以放置A指示物的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 向玩家发出「请选择表侧表示的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只可以放置A指示物的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置本次连锁的操作信息为放置指示物，对象为选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果处理：取得对象怪兽，若其为表侧表示且仍与效果关联，则在其上放置1个A指示物。
function c51192573.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
-- 攻守下降效果的适用条件：仅在伤害计算时且场上存在攻击对象（即有怪兽进行战斗）时适用。
function c51192573.adcon(e)
	-- 判断当前处于伤害计算时且存在攻击对象，即正处于怪兽战斗中。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 筛选适用对象：放置有A指示物且正在和名字带有「外星」的怪兽战斗的怪兽。
function c51192573.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算攻守下降数值：每有1个A指示物，攻击力·守备力下降300。
function c51192573.adval(e,c)
	return c:GetCounter(0x100e)*-300
end

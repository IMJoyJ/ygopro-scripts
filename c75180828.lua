--水精鱗－サルフアビス
-- 效果：
-- 自己的主要阶段时，从手卡把4只名字带有「水精鳞」的怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤时，这张卡的攻击力上升500，选择最多有自己墓地的名字带有「水精鳞」的怪兽数量的对方场上的卡破坏。此外，可以通过把这张卡以外的表侧攻击表示存在的1只名字带有「水精鳞」的怪兽解放，这个回合这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
function c75180828.initial_effect(c)
	-- 自己的主要阶段时，从手卡把4只名字带有「水精鳞」的怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75180828,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c75180828.spcost)
	e1:SetTarget(c75180828.sptg)
	e1:SetOperation(c75180828.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤时，这张卡的攻击力上升500，选择最多有自己墓地的名字带有「水精鳞」的怪兽数量的对方场上的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75180828,1))  --"破坏"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c75180828.descon)
	e2:SetTarget(c75180828.destg)
	e2:SetOperation(c75180828.desop)
	c:RegisterEffect(e2)
	-- 此外，可以通过把这张卡以外的表侧攻击表示存在的1只名字带有「水精鳞」的怪兽解放，这个回合这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75180828,2))  --"效果附加"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c75180828.atkcon)
	e3:SetCost(c75180828.atkcost)
	e3:SetTarget(c75180828.atktg)
	e3:SetOperation(c75180828.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中名字带有「水精鳞」且可以丢弃去墓地的怪兽
function c75180828.cfilter(c)
	return c:IsSetCard(0x74) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的代价：从手卡丢弃4只「水精鳞」怪兽
function c75180828.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的4只及以上名字带有「水精鳞」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75180828.cfilter,tp,LOCATION_HAND,0,4,e:GetHandler()) end
	-- 从手卡选择4只名字带有「水精鳞」的怪兽丢弃去墓地
	Duel.DiscardHand(tp,c75180828.cfilter,4,4,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 特殊召唤效果的目标：检查怪兽区域是否有空位以及自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c75180828.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将自身特殊召唤到场上
function c75180828.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以自身效果特殊召唤到自己场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 破坏效果的发动条件：自身通过自身效果特殊召唤成功
function c75180828.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：自己墓地中名字带有「水精鳞」的怪兽
function c75180828.descount(c)
	return c:IsSetCard(0x74) and c:IsType(TYPE_MONSTER)
end
-- 破坏效果的目标：选择最多有自己墓地「水精鳞」怪兽数量的对方场上的卡作为对象，并设置破坏的操作信息
function c75180828.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	-- 获取自己墓地中名字带有「水精鳞」的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c75180828.descount,tp,LOCATION_GRAVE,0,nil)
	if ct>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择最多有自己墓地「水精鳞」怪兽数量的对方场上的卡作为效果对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 设置破坏的操作信息，包含选中的卡片组
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 破坏效果的执行：自身攻击力上升500，并破坏选中的对方场上的卡
function c75180828.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 获取当前连锁中仍存在于场上且与效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏选中的卡片
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果附加的发动条件：自己的主要阶段1
function c75180828.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤条件：自己场上表侧攻击表示存在的名字带有「水精鳞」的怪兽
function c75180828.rfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x74)
end
-- 效果附加的代价：解放自身以外的1只表侧攻击表示的「水精鳞」怪兽
function c75180828.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除自身以外可解放的表侧攻击表示的「水精鳞」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c75180828.rfilter,1,e:GetHandler()) end
	-- 选择1只除自身以外的表侧攻击表示的「水精鳞」怪兽
	local g=Duel.SelectReleaseGroup(tp,c75180828.rfilter,1,1,e:GetHandler())
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果附加的目标：检查本回合是否尚未发动过此效果
function c75180828.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(75180828)==0 end
end
-- 效果附加的执行：给自身注册一个「向守备表示怪兽攻击时不进行伤害计算直接破坏」的诱发效果，并添加已发动标记
function c75180828.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这个回合这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(75180828,3))
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetTarget(c75180828.destg2)
		e1:SetOperation(c75180828.desop2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(75180828,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 附加效果的破坏目标：检查自身是否为攻击怪兽且攻击对象为守备表示怪兽，并设置破坏的操作信息
function c75180828.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击对象（防守方怪兽）
	local d=Duel.GetAttackTarget()
	-- 检查自身是否为攻击怪兽，且存在攻击对象，且该对象为守备表示
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and d~=nil and d:IsDefensePos() end
	-- 设置破坏的操作信息，包含攻击对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 附加效果的破坏执行：不进行伤害计算，直接破坏该守备表示怪兽
function c75180828.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() and d:IsDefensePos() then
		-- 破坏该守备表示怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end

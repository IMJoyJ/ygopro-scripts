--双天拳 鎧阿
-- 效果：
-- 「双天」怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏。这个效果的发动后，直到回合结束时这张卡不能直接攻击。
-- ②：只要效果怪兽为素材作融合召唤的「双天」融合怪兽在自己场上存在，自己场上的「双天」融合怪兽的攻击力·守备力上升300。
function c60237530.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要2只「双天」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true)
	-- ②：只要效果怪兽为素材作融合召唤的「双天」融合怪兽在自己场上存在
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c60237530.matcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏。这个效果的发动后，直到回合结束时这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60237530,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,60237530)
	e1:SetTarget(c60237530.target)
	e1:SetOperation(c60237530.operation)
	c:RegisterEffect(e1)
	-- ②：只要效果怪兽为素材作融合召唤的「双天」融合怪兽在自己场上存在，自己场上的「双天」融合怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c60237530.adcon)
	e2:SetTarget(c60237530.ffilter)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 融合素材检查，若融合素材中存在效果怪兽，则给这张卡注册一个特定的Flag标记
function c60237530.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
-- ①号效果的发动准备与目标选择，确认对方场上是否存在攻击表示怪兽，并将其作为效果对象
function c60237530.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAttackPos() end
	-- 在效果发动阶段，检查对方场上是否存在至少1只可以作为对象的攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表明该连锁将破坏所选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①号效果的实际处理，破坏选中的对象怪兽，并给自身施加本回合不能直接攻击的限制
function c60237530.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽以及当前发动效果的卡片自身
	local tc,c=Duel.GetFirstTarget(),e:GetHandler()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为效果对象的怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上的「双天」融合怪兽
function c60237530.ffilter(e,c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x14f)
end
-- 过滤出自己场上表侧表示存在、且以效果怪兽为素材融合召唤的「双天」融合怪兽
function c60237530.fmfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x14f) and c:IsFaceup() and c:GetFlagEffect(85360035)~=0
end
-- 判断②号效果的适用条件，即自己场上是否存在以效果怪兽为素材融合召唤的「双天」融合怪兽
function c60237530.adcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1只表侧表示且带有特定Flag标记（以效果怪兽为素材融合召唤）的「双天」融合怪兽
	return Duel.IsExistingMatchingCard(c60237530.fmfilter,tp,LOCATION_MZONE,0,1,nil)
end

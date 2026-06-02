--救世の美神ノースウェムコ
-- 效果：
-- 「救世的仪式」降临。这张卡仪式召唤成功时，选择最多有这张卡的仪式召唤使用的怪兽数量的这张卡以外的场上表侧表示存在的卡发动。只要选择的卡在场上表侧表示存在，这张卡不会被卡的效果破坏。
function c61757117.initial_effect(c)
	aux.AddCodeList(c,60234913)
	c:EnableReviveLimit()
	-- 这张卡仪式召唤成功时，选择最多有这张卡的仪式召唤使用的怪兽数量的这张卡以外的场上表侧表示存在的卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(61757117,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c61757117.condition)
	e1:SetTarget(c61757117.target)
	e1:SetOperation(c61757117.operation)
	c:RegisterEffect(e1)
	-- 只要选择的卡在场上表侧表示存在，这张卡不会被卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c61757117.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 确认这张卡是否是通过仪式召唤特殊召唤成功的
function c61757117.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 选择效果对象：获取仪式召唤使用的怪兽数量，并选择最多该数量的、除自身以外的场上表侧表示的卡
function c61757117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	-- 在客户端显示提示信息，要求玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1张到最多等同于仪式素材数量的、除自身以外的场上表侧表示的卡作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,c)
end
-- 效果处理：将选择的卡与这张卡建立效果对象（CardTarget）连接，用于后续的抗性判断
function c61757117.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	while tc do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then c:SetCardTarget(tc) end
		tc=g:GetNext()
	end
end
-- 判断这张卡当前指向的效果对象数量是否大于0，作为抗性生效的条件
function c61757117.indcon(e)
	return e:GetHandler():GetCardTargetCount()>0
end

--救世の美神ノースウェムコ
-- 效果：
-- 「救世的仪式」降临。这张卡仪式召唤成功时，选择最多有这张卡的仪式召唤使用的怪兽数量的这张卡以外的场上表侧表示存在的卡发动。只要选择的卡在场上表侧表示存在，这张卡不会被卡的效果破坏。
function c61757117.initial_effect(c)
	-- 在卡片的关联卡列表中添加「救世的仪式」的卡片密码
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
-- 检查触发此效果的卡是否是通过仪式召唤特殊召唤成功
function c61757117.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 选择最多有该卡仪式召唤所使用的素材怪兽数量的、该卡以外的场上表侧表示存在的卡作为对象
function c61757117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	-- 提示玩家选择场上表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1张以上、最多为该卡仪式召唤时使用素材数量的该卡以外的场上表侧表示的卡作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,c)
end
-- 在效果处理时，使被选择的对象卡片与自身建立卡片效果对象的关联（指向关系）
function c61757117.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	while tc do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then c:SetCardTarget(tc) end
		tc=g:GetNext()
	end
end
-- 检查这张卡指向的效果对象卡片数量是否大于0，作为自身不会被卡的效果破坏效果的适用条件
function c61757117.indcon(e)
	return e:GetHandler():GetCardTargetCount()>0
end

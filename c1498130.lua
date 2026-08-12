--六武衆の影武者
-- 效果：
-- 自己场上表侧表示存在的名字带有「六武众」的怪兽1只成为魔法·陷阱·效果怪兽的效果的对象时，可以把那个效果的对象转换为场上表侧表示存在的这张卡。
function c1498130.initial_effect(c)
	-- 创建一个诱发即时效果，用于处理连锁中对象的转移
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1498130,0))  --"对象转移"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1498130.tgcon)
	e1:SetOperation(c1498130.tgop)
	c:RegisterEffect(e1)
end
-- 检查当前连锁是否为取对象效果，且对象卡片组数量为1，且对象为己方表侧表示的六武众怪兽
function c1498130.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc==c or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsLocation(LOCATION_MZONE) or not tc:IsSetCard(0x103d) then return false end
	-- 确认当前效果对象是否可以被转换为这张卡
	return Duel.CheckChainTarget(ev,c)
end
-- 当效果发动时，将连锁对象转换为这张卡
function c1498130.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Group.CreateGroup()
		g:AddCard(c)
		-- 将连锁效果的对象更换为这张卡
		Duel.ChangeTargetCard(ev,g)
	end
end

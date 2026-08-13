--六武衆の影武者
-- 效果：
-- 自己场上表侧表示存在的名字带有「六武众」的怪兽1只成为魔法·陷阱·效果怪兽的效果的对象时，可以把那个效果的对象转换为场上表侧表示存在的这张卡。
function c1498130.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「六武众」的怪兽1只成为魔法·陷阱·效果怪兽的效果的对象时，可以把那个效果的对象转换为场上表侧表示存在的这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1498130,0))  --"对象转移"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1498130.tgcon)
	e1:SetOperation(c1498130.tgop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：确认当前连锁的效果是取对象效果、对象仅有1只怪兽，且该怪兽是己方场上表侧表示的名字带有「六武众」的怪兽（不是本卡），同时本卡可以合法成为该效果的新对象。
function c1498130.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果的对象卡组，以便检查对象是否满足被转移的条件。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc==c or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsLocation(LOCATION_MZONE) or not tc:IsSetCard(0x103d) then return false end
	-- 检查本卡是否能成为当前连锁效果的合法对象，确保对象转移后效果仍能正常处理。
	return Duel.CheckChainTarget(ev,c)
end
-- 效果处理：若本卡仍与发动时的效果相关联且为表侧表示，则将当前连锁效果的对象更换为本卡。
function c1498130.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Group.CreateGroup()
		g:AddCard(c)
		-- 将连锁效果的对象实际替换为仅包含本卡的对象组，完成对象转移。
		Duel.ChangeTargetCard(ev,g)
	end
end

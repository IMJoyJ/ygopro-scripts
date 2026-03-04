--CNo.79 BK 将星のカエサル
-- 效果：
-- 5星怪兽×3
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：1回合1次，对方把怪兽特殊召唤之际才能发动。这张卡2个超量素材取除，那个无效并破坏。
-- ③：这张卡有「No.79 燃烧拳击手 新星之帝环拳士」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，自己的「燃烧拳击手」怪兽和对方怪兽进行战斗的攻击宣言时才能发动。从手卡·卡组把1只「燃烧拳击手」怪兽送去墓地，那只对方怪兽作为这张卡的超量素材。
function c10300821.initial_effect(c)
	-- 为这张卡添加 XYZ 召唤手续，需要 3 只 5 星怪兽作为素材。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10300821.atkval)
	c:RegisterEffect(e1)
	-- ②：1 回合 1 次，对方把怪兽特殊召唤之际才能发动。这张卡 2 个超量素材取除，那个无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10300821,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c10300821.discon)
	e2:SetTarget(c10300821.distg)
	e2:SetOperation(c10300821.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡有「No.79 燃烧拳击手 新星之帝环拳士」在作为超量素材的场合，得到以下效果。●1 回合 1 次，自己的「燃烧拳击手」怪兽和对方怪兽进行战斗的攻击宣言时才能发动。从手卡·卡组把 1 只「燃烧拳击手」怪兽送去墓地，那只对方怪兽作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10300821,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c10300821.tgcon)
	e3:SetTarget(c10300821.tgtg)
	e3:SetOperation(c10300821.tgop)
	c:RegisterEffect(e3)
end
-- 设置这张卡的 XYZ 编号为 79，用于关联「No.」怪兽的卡片效果。
aux.xyz_number[10300821]=79
-- 定义计算攻击力上升值的函数。
function c10300821.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 定义效果②的发动条件函数。
function c10300821.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方特殊召唤且当前不在连锁处理中。
	return ep==1-tp and Duel.GetCurrentChain()==0
end
-- 定义效果②的发动时检查及操作信息设置函数。
function c10300821.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_EFFECT) end
	-- 设置操作信息为无效召唤，对象为特殊召唤的怪兽群。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息为破坏，对象为特殊召唤的怪兽群。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 定义效果②的实际处理函数。
function c10300821.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)>0 then
		-- 无效对方怪兽的特殊召唤。
		Duel.NegateSummon(eg)
		-- 破坏那些特殊召唤的怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义效果③的发动条件函数。
function c10300821.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,71921856) then return false end
	-- 获取当前正在战斗的己方怪兽和对方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsFaceup() and a:IsSetCard(0x1084) then
		e:SetLabelObject(d)
		return true
	else return false end
end
-- 定义筛选送去墓地的「燃烧拳击手」怪兽的过滤函数。
function c10300821.tgfilter(c)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义效果③的发动时检查及对象设置函数。
function c10300821.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:IsCanOverlay()
		-- 检查手卡或卡组是否存在可以送去墓地的「燃烧拳击手」怪兽。
		and Duel.IsExistingMatchingCard(c10300821.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 将对方战斗怪兽设置为效果对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息为从手卡或卡组送去墓地 1 只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果③的实际处理函数。
function c10300821.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示选择送去墓地怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 让玩家从手卡或卡组选择 1 只「燃烧拳击手」怪兽。
	local g=Duel.SelectMatchingCard(tp,c10300821.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽送去墓地并确认是否成功。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取效果对象即对方战斗怪兽。
		local tc=Duel.GetFirstTarget()
		if c:IsRelateToChain() and tc:IsRelateToChain()
			and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将该对方怪兽原有的超量素材送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将那只对方怪兽作为这张卡的超量素材。
			Duel.Overlay(c,tc)
		end
	end
end

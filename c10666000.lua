--No.1 インフェクション・バアル・ゼブル
-- 效果：
-- 8星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。把对方的额外卡组确认，那之内的1张送去墓地。
-- ②：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把表侧表示怪兽破坏的场合，再给与对方那个攻击力一半数值的伤害。
-- ③：自己准备阶段才能发动。把对方墓地1张卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，需要8星怪兽2只以上作为素材
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	-- ①：这张卡超量召唤的场合才能发动。把对方的额外卡组确认，那之内的1张送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atcon)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把表侧表示怪兽破坏的场合，再给与对方那个攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：自己准备阶段才能发动。把对方墓地1张卡作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ编号为1
aux.xyz_number[id]=1
-- 准备阶段效果的条件判断函数
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果的目标选择函数
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方墓地的卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将有1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 准备阶段效果的处理函数
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示选择将卡叠放
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 获取己方墓地的卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 检查是否受到王家长眠之谷影响
	if aux.NecroValleyNegateCheck(g) then return end
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		-- 将选中的卡叠放至自身
		Duel.Overlay(c,tg)
	end
end
-- 效果②的发动条件判断函数
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果②的目标选择函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组中可送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将有1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	-- 确认对方额外卡组的卡
	Duel.ConfirmCards(tp,g,true)
	-- 提示选择将卡送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 洗切对方额外卡组
	Duel.ShuffleExtra(1-tp)
end
-- 效果③的费用支付函数
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的目标选择函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否存在可破坏的目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择目标卡
	local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	-- 设置操作信息，表示将有1张卡被破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	if tc:IsLocation(LOCATION_MZONE) then
		local atk=0
		if tc:IsFaceup() then tc:GetAttack() end
		-- 设置操作信息，表示将给对方造成伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk//2)
	end
end
-- 效果③的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local atk=0
	if tc:IsFaceup() then atk=tc:GetAttack() end
	-- 破坏目标卡并判断是否为怪兽区域的卡
	if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsPreviousLocation(LOCATION_MZONE) and atk>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 给对方造成伤害
		Duel.Damage(1-tp,atk//2,REASON_EFFECT)
	end
end

--No.1 インフェクション・バアル・ゼブル
-- 效果：
-- 8星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。把对方的额外卡组确认，那之内的1张送去墓地。
-- ②：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把表侧表示怪兽破坏的场合，再给与对方那个攻击力一半数值的伤害。
-- ③：自己准备阶段才能发动。把对方墓地1张卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤限制并添加XYZ召唤手续，注册三个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，要求8星怪兽2只以上进行叠放
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	-- 效果③：自己准备阶段才能发动。把对方墓地1张卡作为这张卡的超量素材。
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
	-- 效果①：这张卡超量召唤的场合才能发动。把对方的额外卡组确认，那之内的1张送去墓地。
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
	-- 效果②：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把表侧表示怪兽破坏的场合，再给与对方那个攻击力一半数值的伤害。
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
-- 设置该卡为No.1系列怪兽
aux.xyz_number[id]=1
-- 准备阶段效果的发动条件，判断是否为当前回合玩家
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果的发动时点处理，检索满足条件的卡片组
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方墓地的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将要将1张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 准备阶段效果的发动处理，选择并叠放墓地的卡作为超量素材
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 获取己方墓地的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 检查是否受到王家长眠之谷影响，若受影响则不继续处理
	if aux.NecroValleyNegateCheck(g) then return end
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		-- 将选择的卡叠放至该卡上
		Duel.Overlay(c,tg)
	end
end
-- 效果①的发动条件，判断是否为XYZ召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的发动时点处理，检索满足条件的卡片组
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将要将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的发动处理，确认对方额外卡组并选择1张送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	-- 确认对方额外卡组的卡片
	Duel.ConfirmCards(tp,g,true)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
	-- 将选择的卡送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 将对方额外卡组洗切
	Duel.ShuffleExtra(1-tp)
end
-- 效果②的发动费用处理，移除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动时点处理，选择目标并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否能选择对方场上1张卡作为目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为目标
	local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	-- 设置操作信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	if tc:IsLocation(LOCATION_MZONE) then
		local atk=0
		if tc:IsFaceup() then tc:GetAttack() end
		-- 设置操作信息，表示将要给予对方伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk//2)
	end
end
-- 效果②的发动处理，破坏目标卡并根据条件给予伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local atk=0
	if tc:IsFaceup() then atk=tc:GetAttack() end
	-- 判断破坏是否成功且目标为表侧表示怪兽且攻击力大于0
	if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsPreviousLocation(LOCATION_MZONE) and atk>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 给予对方目标怪兽攻击力一半数值的伤害
		Duel.Damage(1-tp,atk//2,REASON_EFFECT)
	end
end

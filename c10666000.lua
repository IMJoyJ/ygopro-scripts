--No.1 インフェクション・バアル・ゼブル
-- 效果：
-- 8星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。把对方的额外卡组确认，那之内的1张送去墓地。
-- ②：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把表侧表示怪兽破坏的场合，再给与对方那个攻击力一半数值的伤害。
-- ③：自己准备阶段才能发动。把对方墓地1张卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化函数：启用召唤限制（仅可通过超量召唤从额外卡组特殊召唤），添加8星怪兽×2只以上的超量召唤手续，并注册三个效果：③自己准备阶段将对方墓地1张卡作为超量素材；①超量召唤成功时确认对方额外卡组并把其中1张送去墓地；②取除1个超量素材破坏对方场上1张卡并可能造成伤害。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：以8星怪兽2只以上（最多99只）作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	-- ③：自己准备阶段才能发动。把对方墓地1张卡作为这张卡的超量素材。
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
	-- ①：这张卡超量召唤的场合才能发动。把对方的额外卡组确认，那之内的1张送去墓地。
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
	-- ②：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把表侧表示怪兽破坏的场合，再给与对方那个攻击力一半数值的伤害。
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
-- 将这张卡的No.编号注册为1，使涉及No.1的相关效果能正确识别。
aux.xyz_number[id]=1
-- ③效果的发动条件：这张卡在怪兽区域存在，且当前为这张卡的控制者的准备阶段。
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，即是否是自己准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- ③效果的发动目标：对方墓地存在卡时才能发动；同时设定操作信息为涉及墓地的效果，便于与王家长眠之谷等效果联动。
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方墓地所有卡，作为之后选择超量素材的候选集合。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	if chk==0 then return #g>0 end
	-- 设定本次连锁的操作信息：涉及墓地卡片1张，用于王家长眠之谷等效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果处理：从对方墓地选择1张卡，叠放在这张卡下面作为超量素材；若对方墓地的卡受王家长眠之谷影响则效果不处理。
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家显示选择提示：请选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 重新获取对方墓地所有卡，用于进行选择。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 检查目标卡组是否受到王家长眠之谷的影响，若受到影响则本次效果被无效并中止处理。
	if aux.NecroValleyNegateCheck(g) then return end
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		-- 将选中的卡叠放到这张卡下方，成为这张卡的超量素材。
		Duel.Overlay(c,tg)
	end
end
-- ①效果的发动条件：这张卡以超量召唤方式特殊召唤成功的场合。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果的发动目标：对方额外卡组中存在可以送去墓地的卡时才能发动；并设定将1张卡送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组中所有可以被效果送去墓地的卡，作为候选集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g>0 end
	-- 设定本次连锁的操作信息：送去墓地的卡1张，用于效果处理时检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ①效果处理：确认对方额外卡组，由玩家选择其中1张可以送去墓地的卡送去墓地，之后洗切对方额外卡组。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的全部卡，准备进行确认和选择。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	-- 将对方额外卡组的所有卡展示给玩家tp确认。
	Duel.ConfirmCards(tp,g,true)
	-- 向玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
	-- 将选中的卡以效果原因送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 洗切对方的额外卡组（因为从中移动了卡）。
	Duel.ShuffleExtra(1-tp)
end
-- ②效果的发动代价：取除这张卡的1个超量素材作为COST。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的发动目标：以对方场上1张卡为对象才能发动；若对象为表侧表示怪兽，则额外设定造成其攻击力一半数值伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动时检查对方场上是否存在至少1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡作为效果对象，并取得该卡。
	local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	-- 设定本次连锁的操作信息：破坏对象卡1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	if tc:IsLocation(LOCATION_MZONE) then
		local atk=0
		if tc:IsFaceup() then tc:GetAttack() end
		-- 设定本次连锁的操作信息：给对方造成对象怪兽攻击力一半数值的伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk//2)
	end
end
-- ②效果处理：破坏对象卡；若破坏的是表侧表示怪兽且其攻击力大于0，则给对方造成该攻击力一半数值的伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local atk=0
	if tc:IsFaceup() then atk=tc:GetAttack() end
	-- 若对象卡被效果成功破坏，且破坏前位于怪兽区域，并且记录的atk值大于0，则进入后续伤害处理。
	if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsPreviousLocation(LOCATION_MZONE) and atk>0 then
		-- 中断当前效果连锁，使伤害处理单独进行，确保破坏成功后再结算伤害。
		Duel.BreakEffect()
		-- 给对方造成对象怪兽攻击力一半数值的伤害。
		Duel.Damage(1-tp,atk//2,REASON_EFFECT)
	end
end

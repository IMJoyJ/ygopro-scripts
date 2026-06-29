--魔降雷
local s,id,o=GetID()
-- 注册激活卡片改变攻击力并选择破坏怪兽的效果、以及墓地回收恶魔族怪兽的效果
function s.initial_effect(c)
	-- ①：以自己场上1只「魔界剧团」怪兽为对象才能发动。那只怪兽的攻击力上升600。那之后，可以把持有比那只怪兽的攻击力低的原本攻击力的对方场上的怪兽全部破坏。这个效果在伤害步骤也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：墓地的这张卡除外才能发动。从墓地选择1只攻击力2500的恶魔族·6星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的此卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 可作为对象的自己场上表侧表示「魔界剧团」怪兽的过滤条件
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 增加攻击力及破坏效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否存在表侧表示的「魔界剧团」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示，请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「魔界剧团」怪兽为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 对方场上原本攻击力低于选定怪兽当前攻击力的表侧表示怪兽的过滤条件
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk
end
-- 增加攻击力及破坏效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的自己场上「魔界剧团」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 刷新并重新计算场上所有怪兽的攻击力及相关状态
		Duel.AdjustAll()
		local atk=tc:GetAttack()
		-- 检查对方场上是否存在满足破坏过滤条件的怪兽
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)
			-- 询问玩家是否破坏满足条件的对方怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 切断效果处理 of the chain
			Duel.BreakEffect()
			-- 获取对方场上所有满足破坏条件的怪兽
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
			-- 破坏所有选中的对方场上怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 可加入手卡的攻击力2500的恶魔族·6星怪兽的过滤条件
function s.thfilter(c)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsAbleToHand()
end
-- 墓地回收效果的发动准备与对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地中是否存在满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将选中的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 墓地回收效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡片是否未受墓地无效效果的影响且依然与连锁关联
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end

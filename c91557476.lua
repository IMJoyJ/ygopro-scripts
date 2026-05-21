--聖蔓の剣士
-- 效果：
-- 植物族通常怪兽1只
-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
-- ②：这张卡特殊召唤成功的场合，以场上1只「圣天树」连接怪兽为对象才能发动。这张卡的攻击力上升那个连接标记数量×800。
-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在作为连接怪兽所连接区的自己场上效果无效特殊召唤。
function c91557476.initial_effect(c)
	-- 添加连接召唤手续：植物族通常怪兽1只
	aux.AddLinkProcedure(c,c91557476.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91557476,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c91557476.descon)
	e1:SetTarget(c91557476.destg)
	e1:SetOperation(c91557476.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以场上1只「圣天树」连接怪兽为对象才能发动。这张卡的攻击力上升那个连接标记数量×800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91557476,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(c91557476.atktg)
	e2:SetOperation(c91557476.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在作为连接怪兽所连接区的自己场上效果无效特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91557476,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置发动条件：自身战斗破坏对方怪兽并送去墓地
	e3:SetCondition(aux.bdogcon)
	e3:SetTarget(c91557476.sptg)
	e3:SetOperation(c91557476.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：植物族通常怪兽
function c91557476.mfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and c:IsLinkRace(RACE_PLANT)
end
-- 过滤条件：原本在自己场上表侧表示存在的「圣天树」连接怪兽因效果离场
function c91557476.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsPreviousSetCard(0x2158) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 设置效果1的发动条件：存在满足离场条件的「圣天树」连接怪兽
function c91557476.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91557476.cfilter,1,nil,tp)
end
-- 设置效果1的靶向：必发效果，直接返回true，并设置破坏自身的操作信息
function c91557476.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果1的操作：若自身在场，则将自身破坏
function c91557476.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤条件：场上的「圣天树」连接怪兽
function c91557476.atkfilter(c)
	return c:IsSetCard(0x2158) and c:IsType(TYPE_LINK) and c:IsLinkAbove(1)
end
-- 设置效果2的靶向：选择场上1只「圣天树」连接怪兽作为对象
function c91557476.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c91557476.atkfilter(chkc) end
	-- 检查场上是否存在可以作为对象的「圣天树」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c91557476.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1只符合条件的「圣天树」连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91557476.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果2的操作：使这张卡的攻击力上升作为对象的怪兽的连接标记数量×800
function c91557476.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的怪兽以及这张卡自身
	local tc,c=Duel.GetFirstTarget(),e:GetHandler()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetLink()>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那个连接标记数量×800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(tc:GetLink()*800)
		c:RegisterEffect(e1)
	end
end
-- 设置效果3的靶向：检查是否有可用的连接区域，以及被破坏的怪兽是否可以特殊召唤
function c91557476.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 获取自己场上所有连接怪兽所连接的区域（前锋怪兽区域）
	local zone=Duel.GetLinkedZone(tp)&0x1f
	-- 检查在连接怪兽所连接的区域中是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将被战斗破坏的怪兽设为效果处理的目标
	Duel.SetTargetCard(bc)
	-- 设置操作信息：特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果3的操作：将被破坏的怪兽在连接怪兽所连接的自己场上效果无效特殊召唤
function c91557476.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取要特殊召唤的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 重新获取当前可用的连接区域
	local zone=Duel.GetLinkedZone(tp)&0x1f
	if zone~=0 and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽以表侧表示特殊召唤到可用的连接区域
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end

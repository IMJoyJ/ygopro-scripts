--聖蔓の癒し手
-- 效果：
-- 植物族通常怪兽1只
-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
-- ②：这张卡特殊召唤成功的场合，以场上1只「圣天树」连接怪兽为对象才能发动。自己回复那个连接标记数量×300基本分。
-- ③：自己的植物族连接怪兽给与对方战斗伤害时才能发动。自己回复600基本分。
function c65563871.initial_effect(c)
	-- 设置连接召唤手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c65563871.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65563871,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c65563871.descon)
	e1:SetTarget(c65563871.destg)
	e1:SetOperation(c65563871.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以场上1只「圣天树」连接怪兽为对象才能发动。自己回复那个连接标记数量×300基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65563871,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(c65563871.rectg)
	e2:SetOperation(c65563871.recop)
	c:RegisterEffect(e2)
	-- ③：自己的植物族连接怪兽给与对方战斗伤害时才能发动。自己回复600基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65563871,2))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c65563871.recon)
	e3:SetTarget(c65563871.retg)
	e3:SetOperation(c65563871.reop)
	c:RegisterEffect(e3)
end
-- 过滤连接素材：植物族的通常怪兽
function c65563871.mfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and c:IsLinkRace(RACE_PLANT)
end
-- 过滤因效果从场上离开的自己场上的表侧表示「圣天树」连接怪兽
function c65563871.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsPreviousSetCard(0x2158) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：存在满足过滤条件的因效果离场的卡
function c65563871.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65563871.cfilter,1,nil,tp)
end
-- 效果①的发动准备：设置破坏自身的操作信息
function c65563871.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果①的处理：若自身在场则将其破坏
function c65563871.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤场上的「圣天树」连接怪兽
function c65563871.recfilter(c)
	return c:IsSetCard(0x2158) and c:IsType(TYPE_LINK) and c:IsLinkAbove(1)
end
-- 效果②的发动准备：选择场上1只「圣天树」连接怪兽为对象，并设置回复LP的操作信息
function c65563871.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c65563871.recfilter(chkc) end
	-- 检查场上是否存在可以作为对象的「圣天树」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c65563871.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1只「圣天树」连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c65563871.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为回复对象怪兽连接标记数量×300的LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetLink()*300)
end
-- 效果②的处理：自己回复对象怪兽连接标记数量×300的LP
function c65563871.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetLink()>0 then
		-- 自己回复对象怪兽连接标记数量×300的LP
		Duel.Recover(tp,tc:GetLink()*300,REASON_EFFECT)
	end
end
-- 效果③的发动条件：自己的植物族连接怪兽给与对方战斗伤害
function c65563871.recon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsType(TYPE_LINK) and tc:IsRace(RACE_PLANT)
end
-- 效果③的发动准备：设置回复600LP的操作信息和目标玩家
function c65563871.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复LP的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复LP的数值为600
	Duel.SetTargetParam(600)
	-- 设置当前连锁的操作信息为回复600LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end
-- 效果③的处理：自己回复600LP
function c65563871.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复LP的处理
	Duel.Recover(p,d,REASON_EFFECT)
end

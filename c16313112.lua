--転生炎獣エメラルド・イーグル
-- 效果：
-- 「转生炎兽的降临」降临。
-- ①：这张卡使用自己场上的「转生炎兽 翠玉鹰」作仪式召唤成功时才能发动。对方场上的特殊召唤的怪兽全部破坏。
-- ②：1回合1次，把自己场上1只「转生炎兽」连接怪兽解放才能发动。这个回合，这张卡得到以下效果。
-- ●这张卡和对方怪兽进行战斗的伤害步骤开始时发动。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c16313112.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡使用自己场上的「转生炎兽 翠玉鹰」作仪式召唤成功时才能发动。对方场上的特殊召唤的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16313112,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c16313112.descon)
	e1:SetTarget(c16313112.destg)
	e1:SetOperation(c16313112.desop)
	c:RegisterEffect(e1)
	-- 检查是否使用了「转生炎兽 翠玉鹰」作为仪式召唤的素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c16313112.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己场上1只「转生炎兽」连接怪兽解放才能发动。这个回合，这张卡得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16313112,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c16313112.effcost)
	e3:SetOperation(c16313112.effop)
	c:RegisterEffect(e3)
end
-- 判断是否为仪式召唤且使用了「转生炎兽 翠玉鹰」作为素材
function c16313112.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 检索对方场上所有特殊召唤的怪兽
function c16313112.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL) end
	-- 获取对方场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	-- 设置连锁操作信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 将对方场上所有特殊召唤的怪兽破坏
function c16313112.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	-- 执行破坏效果
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断是否为「转生炎兽 翠玉鹰」且在场上由自己控制
function c16313112.valfilter(c,tp)
	return c:IsCode(16313112) and c:IsOnField() and c:IsControler(tp)
end
-- 检查仪式召唤时是否使用了「转生炎兽 翠玉鹰」作为素材
function c16313112.valcheck(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	if g:IsExists(c16313112.valfilter,1,nil,tp) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 筛选自己场上的「转生炎兽」连接怪兽
function c16313112.cfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- 检查是否可以解放一只「转生炎兽」连接怪兽作为代价
function c16313112.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以解放一只「转生炎兽」连接怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c16313112.cfilter,1,nil) end
	-- 选择一只「转生炎兽」连接怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c16313112.cfilter,1,1,nil)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置战斗时触发的效果
function c16313112.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- ●这张卡和对方怪兽进行战斗的伤害步骤开始时发动。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(16313112,2))
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetCondition(c16313112.descon2)
		e1:SetTarget(c16313112.destg2)
		e1:SetOperation(c16313112.desop2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 获取战斗中攻击的对方怪兽
function c16313112.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 若攻击目标为自身，则获取攻击怪兽
	if d==e:GetHandler() then d=Duel.GetAttacker() end
	e:SetLabelObject(d)
	return d~=nil
end
-- 设置战斗开始时的处理信息
function c16313112.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local d=e:GetLabelObject()
	-- 设置要破坏的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
	-- 设置给予对方的伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d:GetBaseAttack())
end
-- 执行战斗破坏与伤害效果
function c16313112.desop2(e,tp,eg,ep,ev,re,r,rp)
	local d=e:GetLabelObject()
	local dam=d:GetBaseAttack()
	-- 判断对方怪兽是否参与战斗且被成功破坏
	if d:IsRelateToBattle() and Duel.Destroy(d,REASON_EFFECT)~=0 and dam>0 then
		-- 给予对方相当于对方怪兽攻击力的伤害
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end

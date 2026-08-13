--ダイナレスラー・キメラ・Tレッスル
-- 效果：
-- 「恐龙摔跤手」连接怪兽＋「恐龙摔跤手」怪兽
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方不能选择其他怪兽作为攻击对象。
-- ④：这张卡战斗破坏怪兽的场合发动。这张卡的攻击力上升500。
-- ⑤：这张卡被效果破坏的场合发动。对方的攻击表示怪兽全部破坏。
function c22900219.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材需要1只「恐龙摔跤手」连接怪兽和1只「恐龙摔跤手」怪兽，两者均需满足对应字段/类型条件。
	aux.AddFusionProcFun2(c,c22900219.matfilter1,aux.FilterBoolFunction(Card.IsFusionSetCard,0x11a),true)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c22900219.actlimit)
	e1:SetCondition(c22900219.actcon)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c22900219.atklimit)
	c:RegisterEffect(e3)
	-- ④：这张卡战斗破坏怪兽的场合发动。这张卡的攻击力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c22900219.atkcon)
	e4:SetOperation(c22900219.atkop)
	c:RegisterEffect(e4)
	-- ⑤：这张卡被效果破坏的场合发动。对方的攻击表示怪兽全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c22900219.descon)
	e5:SetTarget(c22900219.destg)
	e5:SetOperation(c22900219.desop)
	c:RegisterEffect(e5)
end
-- 融合素材过滤函数：用于筛选「恐龙摔跤手」连接怪兽，要求怪兽既是连接怪兽又属于「恐龙摔跤手」字段。
function c22900219.matfilter1(c)
	return c:IsFusionType(TYPE_LINK) and c:IsFusionSetCard(0x11a)
end
-- 效果①的限制判断函数：若对方发动的效果属于魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），则禁止其发动。
function c22900219.actlimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果①的适用条件：当前战斗的攻击怪兽或攻击对象是这张卡，即这张卡正在进行战斗时，该封锁效果才生效。
function c22900219.actcon(e)
	-- 判定这张卡是否正在进行战斗：若攻击怪兽或攻击对象是这张卡则返回真。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 攻击对象限制判断函数：对除这张卡以外的其他怪兽返回真，使对方不能选择其他怪兽作为攻击对象，只能攻击这张卡。
function c22900219.atklimit(e,c)
	return c~=e:GetHandler()
end
-- ④效果的发动条件：此卡表侧表示且与本次战斗存在关联（参与战斗并被破坏后仍关联）时才能发动。
function c22900219.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
-- ④效果处理：若此卡仍表侧且与效果关联，则给它附加一个攻击力上升500的效果，该效果在离场、被重置或被无效时失效。
function c22900219.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ⑤效果的发动条件：此卡是被效果破坏（REASON_EFFECT）的场合。
function c22900219.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ⑤效果的发动判定：允许发动；然后将对方场上所有攻击表示怪兽登记为本次破坏效果的操作信息，用于连锁判定。
function c22900219.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有攻击表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	-- 设置本次连锁的操作信息：类别为破坏，目标为对方场上攻击表示怪兽组，数量为该组怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ⑤效果处理：重新获取对方场上所有攻击表示怪兽，若存在则将其全部破坏。
function c22900219.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取当前对方场上所有攻击表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因将这些攻击表示怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end

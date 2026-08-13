--ターボ・ウォリアー
-- 效果：
-- 「涡轮同调士」＋调整以外的怪兽1只以上
-- 6星以上的同调怪兽为攻击对象的这张卡的攻击宣言时，攻击对象怪兽的攻击力直到伤害步骤结束时变成一半。场上的这张卡不会成为6星以下的效果怪兽的效果的对象。
function c46195773.initial_effect(c)
	-- 为涡轮战士声明同调素材列表中包含「涡轮同调士」并将其加入关联码表，用于规则识别召唤素材。
	aux.AddMaterialCodeList(c,67270095)
	-- 给涡轮战士添加同调召唤手续：调整必须满足tfilter（即「涡轮同调士」或其替代素材），调整以外怪兽至少1只且无上限；同时可进行同调召唤。
	aux.AddSynchroProcedure(c,c46195773.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 6星以上的同调怪兽为攻击对象的这张卡的攻击宣言时，攻击对象怪兽的攻击力直到伤害步骤结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46195773,0))  --"攻击对象攻击变成一半"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c46195773.atktg)
	e1:SetOperation(c46195773.atkop)
	c:RegisterEffect(e1)
	-- 场上的这张卡不会成为6星以下的效果怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c46195773.efilter)
	c:RegisterEffect(e2)
end
c46195773.material_setcode=0x1017
-- 判断怪兽是否为同调素材中的调整：卡名是「涡轮同调士」（67270095），或者带有编号20932152的效果（视为满足素材替代条件的怪兽）。
function c46195773.tfilter(c)
	return c:IsCode(67270095) or c:IsHasEffect(20932152)
end
-- 作为『不能成为效果对象』的判定值：仅当效果发动者的原持有者是等级6以下的效果怪兽时，本卡不能被选为对象；返回true表示该效果不能以此卡为对象。
function c46195773.efilter(e,re,rp)
	return re:GetHandler():IsLevelBelow(6)
end
-- 攻击宣言时的发动条件和关联处理：若攻击对象存在且为表侧表示、等级6以上、属于同调怪兽，则发动条件成立；随后将该攻击对象与效果建立联系，并设置操作信息为表示形式变更（数量1）。
function c46195773.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的攻击目标怪兽；若没有攻击目标则为nil。
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsFaceup() and d:IsLevelAbove(6) and d:IsType(TYPE_SYNCHRO) end
	d:CreateEffectRelation(e)
	-- 将本连锁的操作信息登记为『表示形式变更』，对象为攻击目标d，数量为1，持有者和位置信息置0；该信息用于部分效果检测，尽管实际处理是攻击力减半。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
-- 效果处理：获取发动效果的怪兽与当前攻击目标；若攻击目标仍与效果存在联系，则给它暂时附加『最终攻击力变为当前攻击力一半（向上取整）』的效果，该效果在伤害步骤结束时重置。
function c46195773.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击宣言的攻击目标怪兽；若没有攻击目标则为nil。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToEffect(e) then
		-- 攻击对象怪兽的攻击力直到伤害步骤结束时变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(d:GetAttack()/2))
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e1)
	end
end

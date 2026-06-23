--A BF－叢雲のクサナギ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡同调召唤时适用。这张卡的攻击力直到回合结束时上升那些作为同调素材的同调怪兽的原本攻击力的合计数值。
-- ③：这张卡可以向对方怪兽全部各作1次攻击，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 注册卡片效果及同调召唤手续的初始化函数。
function s.initial_effect(c)
	-- 注册需要1只以上调整以外的怪兽作为素材的同调召唤手续。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.tncon)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：这张卡可以向对方怪兽全部各作1次攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
end
s.treat_itself_tuner=true
-- 检查同调素材的函数：计算作为同调素材的同调怪兽的原本攻击力合计数值，并检查是否使用了「黑羽」怪兽作为素材。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	local sg=g:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	if sg:GetCount()>0 then
		atk=sg:GetSum(Card.GetBaseAttack)
	end
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1,atk)
	else
		e:GetLabelObject():SetLabel(0,atk)
	end
end
-- 效果的发动条件：本卡成功进行同调召唤。
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 同调召唤成功时的效果处理函数：若使用了「黑羽」怪兽作为同调素材则将这张卡当作调整怪兽使用，并且使这张卡的攻击力上升同调素材中同调怪兽原本攻击力合计数值。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res,atk=e:GetLabel()
	if res==1 then
		-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if atk~=0 then
		-- 提示发动了本卡的效果。
		Duel.Hint(HINT_CARD,0,id)
		-- ②：这张卡同调召唤时适用。这张卡的攻击力直到回合结束时上升那些作为同调素材的同调怪兽的原本攻击力的合计数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end

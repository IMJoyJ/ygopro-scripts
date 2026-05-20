--精霊コロゾ
-- 效果：
-- 融合·同调·超量·连接怪兽＋魔法师族怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1张融合·同调·超量·连接怪兽卡和1张魔法师族怪兽卡送去墓地的场合可以特殊召唤。
-- ①：1回合1次，自己或对方的怪兽的攻击宣言时，以那1只怪兽为对象才能发动。那次攻击无效，这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。那之后，可以让作为对象的怪兽回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含召唤限制、融合召唤手续、接触融合手续以及攻击宣言时的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要1只融合/同调/超量/连接怪兽和1只魔法师族怪兽作为素材。
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	-- 添加接触融合的特殊召唤规则，将自己场上的素材送去墓地来特殊召唤。
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_ONFIELD,0,Duel.SendtoGrave,REASON_SPSUMMON)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	-- 限制该卡只能通过融合召唤（或符合其特殊召唤规则的方式）进行特殊召唤。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己或对方的怪兽的攻击宣言时，以那1只怪兽为对象才能发动。那次攻击无效，这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。那之后，可以让作为对象的怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效攻击"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.natg)
	e1:SetOperation(s.naop)
	c:RegisterEffect(e1)
end
s.material_type=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 过滤融合素材1：原本卡片类型为融合、同调、超量或连接的怪兽。
function s.mfilter1(c)
	return bit.band(c:GetOriginalType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_LINK+TYPE_XYZ)~=0
end
-- 过滤融合素材2：场上的魔法师族怪兽，或魔法与陷阱区域中原本种族为魔法师族的卡。
function s.mfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) or (c:IsLocation(LOCATION_SZONE) and bit.band(c:GetOriginalRace(),RACE_SPELLCASTER)~=0)
end
-- 过滤接触融合素材：原本卡片类型为怪兽且能送去墓地的卡。
function s.cfilter(c,fc)
	return c:IsAbleToGraveAsCost() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 攻击无效效果的靶向选择（Target）函数，确认并锁定攻击宣言的怪兽为效果对象。
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	if chkc then return chkc==a end
	if chk==0 then return a~=nil and a:IsCanBeEffectTarget(e) end
	-- 将进行攻击宣言的怪兽设为效果处理的对象。
	Duel.SetTargetCard(a)
end
-- 攻击无效效果的执行（Operation）函数，处理无效攻击、增加攻击力以及后续可能的回手牌操作。
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的攻击怪兽。
	local tc=Duel.GetFirstTarget()
	-- 成功无效攻击，且对象怪兽仍存在、攻击力大于0，且自身在场上表侧表示存在时才继续处理。
	if Duel.NegateAttack() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local preatk=c:GetAttack()
		-- 这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local aftatk=c:GetAttack()
		-- 若攻击力确实上升，且对象怪兽可以回到手卡，则玩家可以选择是否将其送回手卡。
		if preatk<aftatk and tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否让对象怪兽回到手卡？"
			-- 中断当前效果处理，使后续的“回到手卡”处理在时点上不与“攻击力上升”视为同时进行。
			Duel.BreakEffect()
			-- 将作为对象的怪兽送回持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

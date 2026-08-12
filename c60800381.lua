--ジャンク・ウォリアー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤的场合发动。这张卡的攻击力上升自己场上的2星以下的怪兽的攻击力的合计数值。
function c60800381.initial_effect(c)
	-- 将「废品同调士」（卡号63977008）作为特定素材卡号加入该怪兽的素材代码列表中。
	aux.AddMaterialCodeList(c,63977008)
	-- 添加同调召唤手续，要求为满足特定过滤条件的调整怪兽（废品同调士）加上1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,c60800381.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合发动。这张卡的攻击力上升自己场上的2星以下的怪兽的攻击力的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60800381,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c60800381.con)
	e1:SetOperation(c60800381.op)
	c:RegisterEffect(e1)
end
c60800381.material_setcode=0x1017
-- 过滤同调素材中的调整怪兽，要求为「废品同调士」或具有替代其作为同调素材效果的怪兽。
function c60800381.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 检查此卡是否是通过同调召唤的方式特殊召唤成功，作为效果发动的条件。
function c60800381.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤场上表侧表示且等级在2星以下的怪兽。
function c60800381.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(2)
end
-- 效果处理：获取自己场上所有表侧表示的2星以下怪兽，计算它们的攻击力合计值，并使这张卡的攻击力上升该数值。
function c60800381.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有满足过滤条件（表侧表示且2星以下）的怪兽。
	local g=Duel.GetMatchingGroup(c60800381.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=0
		local tc=g:GetFirst()
		while tc do
			atk=atk+tc:GetAttack()
			tc=g:GetNext()
		end
		-- 这张卡的攻击力上升自己场上的2星以下的怪兽的攻击力的合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

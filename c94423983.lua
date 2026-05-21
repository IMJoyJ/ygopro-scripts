--同契魔術
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合，双方不能把和自身场上的怪兽相同种类（仪式·融合·同调·超量·连接）的怪兽特殊召唤。自己场上是仪式·融合·同调·超量·连接怪兽的其中每种都没有2只以上存在的场合，自己场上的全部仪式·融合·同调·超量·连接怪兽的攻击力上升500。
function c94423983.initial_effect(c)
	-- ①：这个回合，双方不能把和自身场上的怪兽相同种类（仪式·融合·同调·超量·连接）的怪兽特殊召唤。自己场上是仪式·融合·同调·超量·连接怪兽的其中每种都没有2只以上存在的场合，自己场上的全部仪式·融合·同调·超量·连接怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94423983,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,94423983+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c94423983.activate)
	c:RegisterEffect(e1)
end
-- 获取怪兽的仪式、融合、同调、超量、连接卡片种类
function c94423983.getTypes(c)
	return c:GetType()&(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 获取指定玩家场上表侧表示的仪式、融合、同调、超量、连接怪兽
function c94423983.getMonsters(tp)
	-- 过滤并返回自己场上表侧表示的仪式、融合、同调、超量、连接怪兽
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):Filter(Card.IsType,nil,TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 效果发动的处理：注册限制双方特殊召唤的效果，并判断自己场上特定种类的怪兽是否每种都不超过1只，若是则使这些怪兽攻击力上升500
function c94423983.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，双方不能把和自身场上的怪兽相同种类（仪式·融合·同调·超量·连接）的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c94423983.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制特殊召唤的全局效果
	Duel.RegisterEffect(e1,tp)
	local g=c94423983.getMonsters(tp)
	if #g>0 and g:GetClassCount(c94423983.getTypes)==#g then
		-- 遍历自己场上所有的仪式、融合、同调、超量、连接怪兽
		for tc in aux.Next(g) do
			-- 自己场上的全部仪式·融合·同调·超量·连接怪兽的攻击力上升500。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 判断准备特殊召唤的怪兽的原本种类是否与场上已有的怪兽种类相同
function c94423983.matchfilter(c,sumc)
	return sumc:GetOriginalType()&c94423983.getTypes(c)>0
end
-- 限制特殊召唤的过滤函数，若准备特殊召唤的怪兽种类与自身场上已有的怪兽种类相同，则不能特殊召唤
function c94423983.sumlimit(e,c,sump)
	local g=c94423983.getMonsters(sump)
	return g:IsExists(c94423983.matchfilter,1,nil,c)
end

--呪縛衆
-- 效果：
-- ①：对方场上的全部表侧表示怪兽直到回合结束时不能解放，也不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 创建并注册此卡的①效果：作为魔法卡在手卡发动，设置效果描述、类型为通常魔法（发动）、发动时点为自由时点、提示时点、发动条件和效果处理函数。
function s.initial_effect(c)
	-- ①：对方场上的全部表侧表示怪兽直到回合结束时不能解放，也不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的发动条件判断函数：确认对方场上有表侧表示怪兽时才能发动本卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查（chk==0）时，返回对方场上是否存在至少1只表侧表示怪兽，作为发动是否合法的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理：获取对方场上全部表侧表示怪兽，对其中每只怪兽赋予不能解放以及不能作为融合·同调·超量·连接召唤素材的永续效果，持续到回合结束。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的全部表侧表示怪兽（以我方视角的对方区域、怪兽区）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历上述怪兽集合，对每只怪兽逐一生效效果。
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_MONSTER) then
			-- 不能解放
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e3:SetValue(s.fuslimit)
			tc:RegisterEffect(e3)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			tc:RegisterEffect(e4)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e5)
			local e6=e1:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e6)
		end
	end
end
-- EFFECT_CANNOT_BE_FUSION_MATERIAL的判定函数：当召唤方式为融合召唤时返回true，使该怪兽不能作为融合素材。
function s.fuslimit(e,c,st)
	return st==SUMMON_TYPE_FUSION
end

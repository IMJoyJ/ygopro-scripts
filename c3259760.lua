--呪縛衆
-- 效果：
-- ①：对方场上的全部表侧表示怪兽直到回合结束时不能解放，也不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 创建并注册一张永续连锁效果，用于在自由时点发动
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
-- 判断是否满足发动条件，即对方场上是否存在至少1只表侧表示怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 对方场上存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 遍历对方场上所有表侧表示怪兽，为每只怪兽设置不能解放和不能作为召唤素材的效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 对检索到的怪兽组进行遍历操作
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_MONSTER) then
			-- 设置怪兽不能被解放（作为上级召唤的祭品）的效果
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
-- 融合素材限制函数，用于限制怪兽不能作为融合召唤的素材
function s.fuslimit(e,c,st)
	return st==SUMMON_TYPE_FUSION
end

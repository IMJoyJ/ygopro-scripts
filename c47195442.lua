--四獣層ウォンキー
-- 效果：
-- 4星怪兽×2只以上
-- ①：场上的这张卡不受其他卡的效果影响。
-- ②：这张卡超量召唤的场合或者自己准备阶段发动。从自己卡组上面把3张卡作为这张卡的超量素材。那之后，这张卡作为超量素材中的怪兽数量的以下效果适用。
-- ●4只以下：这张卡的控制权移给对方。
-- ●5只以上：自己受到这张卡持有的超量素材数量×400伤害，自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册超量召唤手续（4星怪兽2只以上）、苏生限制，并分别注册①的免疫效果和②的准备阶段/超量召唤成功时的两个诱发必发效果。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用任意4星怪兽2只以上作为素材进行超量召唤（最多99只）。
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡超量召唤的场合或者自己准备阶段发动。从自己卡组上面把3张卡作为这张卡的超量素材。那之后，这张卡作为超量素材中的怪兽数量的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atcon1)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	-- ②：这张卡超量召唤的场合或者自己准备阶段发动。从自己卡组上面把3张卡作为这张卡的超量素材。那之后，这张卡作为超量素材中的怪兽数量的以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atcon2)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
end
-- 免疫判定函数：仅当来源效果te的持有者不是本卡e的持有者时返回真，使本卡免疫其他卡的效果，实现①的效果。
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 准备阶段触发效果的条件：当前回合玩家等于本卡控制者tp时满足，即只在自己准备阶段发动。
function s.atcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为tp，从而限定准备阶段效果只在己方准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 超量召唤成功触发效果的条件：本卡以超量召唤方式特殊召唤成功时满足。
function s.atcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果发动前提：本卡是超量怪兽才允许发动（不取对象）。
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
end
-- 效果处理：从卡组顶取最多3张卡叠放为素材；若素材中怪兽数量不足5只则将控制权移给对方；若为5只以上则给予自己全部素材数×400伤害并破坏自己场上所有怪兽。
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计自己卡组的卡片数量，用于防止从卡组顶取出超过剩余卡数的张数。
	local ld=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK,0,nil)
	if ld<1 then return end
	-- 取得自己卡组最上方最多3张卡（若不足则全部），作为即将叠放的超量素材。
	local g=Duel.GetDecktopGroup(tp,math.min(ld,3))
	if c:IsRelateToEffect(e) then
		-- 禁用效果处理结束后自动洗切卡组的检测，因为从卡组顶连续取卡不改变卡组顺序。
		Duel.DisableShuffleCheck()
		-- 将取出的卡组顶卡组作为超量素材叠放在本卡下方。
		Duel.Overlay(c,g)
	end
	-- 中断效果处理，使后续分支操作作为新的效果段处理，从而保证素材数已更新并正确判定分支。
	Duel.BreakEffect()
	if c:GetOverlayGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER)<5 then
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 将这张卡的控制权转移给对方玩家，对应素材中怪兽数量为4只以下的效果。
		Duel.GetControl(c,1-tp)
	else
		-- 给予自己伤害，数值为这张卡当前持有的超量素材数量×400。
		Duel.Damage(tp,c:GetOverlayCount()*400,REASON_EFFECT)
		-- 获取自己场上的全部怪兽，用于后续全部破坏。
		local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 将这些怪兽全部破坏，对应“自己场上的怪兽全部破坏”。
		Duel.Destroy(mg,REASON_EFFECT)
	end
end

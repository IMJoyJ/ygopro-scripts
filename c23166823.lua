--影霊獣使い－セフィラウェンディ
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「灵兽」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 自己对「影灵兽使-神数文蒂」1回合只能有1次特殊召唤。
-- ①：这张卡召唤·灵摆召唤时才能发动。从自己的额外卡组（表侧）把「影灵兽使-神数文蒂」以外的1只「神数」怪兽加入手卡。
function c23166823.initial_effect(c)
	c:SetSPSummonOnce(23166823)
	-- 为该灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤、发动灵摆卡等基础操作。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「灵兽」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c23166823.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·灵摆召唤时才能发动。从自己的额外卡组（表侧）把「影灵兽使-神数文蒂」以外的1只「神数」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c23166823.thtg)
	e3:SetOperation(c23166823.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c23166823.condition)
	c:RegisterEffect(e4)
end
-- 灵摆召唤限制的判定函数：被特殊召唤的怪兽既不是「灵兽」也不是「神数」时禁止灵摆召唤；若属于这两个字段之一则允许灵摆召唤。
function c23166823.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0xb5,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 特殊召唤成功时的追加条件：判定这张卡是以灵摆召唤方式特殊召唤成功的，从而让诱发效果在灵摆召唤成功时也能发动。
function c23166823.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 筛选符合条件的表侧额外卡组怪兽：表侧表示、属于「神数」字段、灵摆怪兽、卡名不是「影灵兽使-神数文蒂」、并且能够加入手卡。
function c23166823.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc4) and c:IsType(TYPE_PENDULUM) and not c:IsCode(23166823) and c:IsAbleToHand()
end
-- 诱发效果的目标判定与操作预告：先检查额外卡组是否存在至少1张符合条件的表侧神数灵摆怪兽；若存在则设定本连锁为将1张额外卡组（表侧）怪兽加入手卡的处理。
function c23166823.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0时）：必须存在至少1张满足filter的卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23166823.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 将本次效果的操作信息登记为CATEGORY_TOHAND（回手牌），预定从自己的额外卡组（表侧）将1张卡加入手卡，供后续时点与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理流程：选择1张符合条件的表侧「神数」灵摆怪兽，加入持有者手卡，并向对方展示这张卡，完成检索效果。
function c23166823.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示，提示文字为“请选择要加入手牌的卡”，用于引导玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己的额外卡组（表侧）中筛选并选择1张满足filter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c23166823.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择出的卡以效果原因送去其持有者的手卡，完成加入手卡的操作。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认刚刚加入手卡的卡，使检索信息对双方可见。
		Duel.ConfirmCards(1-tp,g)
	end
end

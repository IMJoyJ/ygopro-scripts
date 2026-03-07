--ギルフォード・ザ・ライトニング
-- 效果：
-- 这张卡也能把3只怪兽解放作召唤。
-- ①：把3只怪兽解放对这张卡的上级召唤成功的场合发动。对方场上的怪兽全部破坏。
function c36354007.initial_effect(c)
	-- 效果原文内容：这张卡也能把3只怪兽解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36354007,0))  --"解放3只怪兽召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c36354007.ttcon)
	e1:SetOperation(c36354007.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：把3只怪兽解放对这张卡的上级召唤成功的场合发动。对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36354007,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c36354007.descon)
	e2:SetTarget(c36354007.destg)
	e2:SetOperation(c36354007.desop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断是否满足上级召唤的祭品条件，即至少需要3只怪兽作为祭品。
function c36354007.ttcon(e,c,minc)
	if c==nil then return true end
	-- 规则层面操作：检查场上是否存在至少3个可用于通常召唤的祭品。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 规则层面操作：选择并解放3只怪兽用于上级召唤。
function c36354007.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 规则层面操作：向玩家提示选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 规则层面操作：从场上选择恰好3只怪兽作为祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 规则层面操作：将选中的怪兽以召唤和素材的名义进行解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 规则层面操作：判断该卡是否通过上级召唤成功（即是否为3只怪兽解放召唤）。
function c36354007.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF
end
-- 规则层面操作：设置连锁操作信息，确定要破坏对方场上所有怪兽。
function c36354007.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：获取对方场上所有怪兽作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 规则层面操作：设置当前连锁处理中将要破坏的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面操作：对对方场上所有怪兽进行破坏处理。
function c36354007.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取对方场上所有怪兽作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 规则层面操作：以效果原因破坏对方场上所有怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end

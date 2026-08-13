--ギルフォード・ザ・ライトニング
-- 效果：
-- 这张卡也能把3只怪兽解放作召唤。
-- ①：把3只怪兽解放对这张卡的上级召唤成功的场合发动。对方场上的怪兽全部破坏。
function c36354007.initial_effect(c)
	-- 这张卡也能把3只怪兽解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36354007,0))  --"解放3只怪兽召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c36354007.ttcon)
	e1:SetOperation(c36354007.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ①：把3只怪兽解放对这张卡的上级召唤成功的场合发动。对方场上的怪兽全部破坏。
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
-- 召唤规则效果的发动条件判断：若正在处理的召唤怪兽不存在（规则查询用）则直接允许；否则要求「解放3只怪兽」的召唤条件成立，且允许的解放数不超过3。
function c36354007.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查当前是否满足「把3只怪兽解放作召唤」的条件：提供的解放数上限不少于3，且场上存在至少3只可作为祭品的怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 召唤规则效果的处理操作：让玩家选择3只要解放的怪兽，将所选怪兽设定为这张卡的召唤素材，并以召唤手续解放它们。
function c36354007.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 给出选择提示，提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从场上选择3只怪兽作为这张卡上级召唤的祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的3只怪兽以「上级召唤的素材」原因解放，完成召唤手续。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- ①效果的发动条件：这张卡以「解放3只怪兽进行上级召唤」的方式（召唤类型等于上级召唤+自身特殊值）召唤成功时，触发该必发效果。
function c36354007.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF
end
-- ①效果的发动条件与目标阶段：满足条件时必定进入发动；处理前先将对方场上的全部怪兽登记为破坏对象。
function c36354007.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上全部怪兽（不取对象，处理时确定这些卡）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将本次操作信息登记为破坏效果，预定破坏对象为对方场上全部怪兽，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的解决处理：处理时再次取得对方场上全部怪兽，并将它们全部破坏。
function c36354007.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上当前存在的全部怪兽（用于破坏处理）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因将对方场上的全部怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end

--オーロラ・アンギラス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把怪兽特殊召唤。
-- ②：这张卡以外的怪兽召唤的场合发动。这张卡破坏。
function c22386234.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的怪兽召唤的场合发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22386234,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c22386234.destg)
	e2:SetOperation(c22386234.desop)
	c:RegisterEffect(e2)
end
-- 效果②的发动判定：当有怪兽召唤成功时，若召唤的怪兽不是这张卡自身，则满足发动条件；同时登记将破坏这张卡自身的操作信息。
function c22386234.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetFirst()~=e:GetHandler() end
	-- 登记本连锁的操作信息：以效果破坏这张卡自身1张，用于系统联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果②的解决处理：获取这张卡，若它仍表侧表示且与效果保持关联，则将其破坏。
function c22386234.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end

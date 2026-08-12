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
-- 效果处理时判断召唤的怪兽是否为该卡本身，若不是则设置破坏目标
function c22386234.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetFirst()~=e:GetHandler() end
	-- 设置连锁操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时检查自身是否表侧表示且与效果相关联，若是则破坏自身
function c22386234.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身以效果原因破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end

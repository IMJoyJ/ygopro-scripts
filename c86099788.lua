--異星の最終戦士
-- 效果：
-- 「暗黑英雄 尸魔侠」＋「魔力吸收球体」
-- 这张卡特殊召唤时，其他的自己的场上的怪兽全部破坏。只要这张卡在场上存在，互相的其他的怪兽不能召唤·反转召唤·特殊召唤。
function c86099788.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，指定素材为「暗黑英雄 尸魔侠」与「魔力吸收球体」
	aux.AddFusionProcCode2(c,71466592,88472456,true,true)
	-- 这张卡特殊召唤时，其他的自己的场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86099788,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c86099788.target)
	e1:SetOperation(c86099788.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，互相的其他的怪兽不能召唤·反转召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e4)
end
-- 特殊召唤成功时强制诱发效果的Target函数，用于确认发动条件并设置破坏的操作信息
function c86099788.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上除这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 设置连锁的操作信息，表明该效果将破坏自己场上的其他怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 特殊召唤成功时强制诱发效果的Operation函数，执行实际的破坏处理
function c86099788.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上除这张卡（若仍在场）以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 将获取到的怪兽全部因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end

--ヌメロン・ストーム
-- 效果：
-- ①：自己场上有「原数天灵」怪兽存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏，给与对方1000伤害。
function c20936251.initial_effect(c)
	-- ①：自己场上有「原数天灵」怪兽存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20936251.descon)
	e1:SetTarget(c20936251.destg)
	e1:SetOperation(c20936251.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡必须是表侧表示且属于「原数天灵」系列，用于判断自己场上是否存在满足条件的「原数天灵」怪兽。
function c20936251.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x169)
end
-- 发动条件判定：检查自己场上主要怪兽区是否存在至少1只表侧表示且属于「原数天灵」的怪兽。
function c20936251.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsExistingMatchingCard在自己场上主要怪兽区检索至少1只满足cfilter（表侧表示且属「原数天灵」）的怪兽，作为效果能否发动的判定条件。
	return Duel.IsExistingMatchingCard(c20936251.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选对方场上的魔法·陷阱卡，即卡片类型为魔法或陷阱。
function c20936251.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标处理：先检查对方场上是否存在可破坏的魔法·陷阱卡，再获取对方场上全部此类卡并设置破坏与伤害的操作信息。
function c20936251.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性的chk==0判定：对方场上必须存在至少1张除效果持有者卡以外的魔法·陷阱卡才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20936251.desfilter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上除效果持有者卡以外的所有魔法·陷阱卡，用于后续破坏处理的对象集合。
	local sg=Duel.GetMatchingGroup(c20936251.desfilter,tp,0,LOCATION_ONFIELD,c)
	-- 设置破坏操作信息：以当前获取的全部对方魔法·陷阱卡作为本次效果将破坏的对象，数量为sg:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置伤害操作信息：预定对对方玩家造成1000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：重新获取对方场上所有魔法·陷阱卡并全部破坏，若破坏成功则给与对方1000点伤害。
function c20936251.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取对方场上除效果持有者卡以外的所有魔法·陷阱卡，确保不取对象地处理全部符合条件的卡。
	local sg=Duel.GetMatchingGroup(c20936251.desfilter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因破坏sg中的魔法·陷阱卡，若实际破坏数量大于0则执行后续伤害。
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
		-- 给与对方玩家1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

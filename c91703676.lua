--炎王神天焼
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上的「炎王」怪兽和对方场上的卡各相同数量为对象才能发动。那些卡破坏。
-- ②：自己场上的「炎王」卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上卡片破坏）和②效果（墓地代破）
function s.initial_effect(c)
	-- ①：以自己场上的「炎王」怪兽和对方场上的卡各相同数量为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「炎王」卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「炎王」怪兽，且能成为效果对象
function s.filter(c,e)
	return c:IsSetCard(0x81) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- ①效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=aux.SelectSameCount(tp,g1,g2)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- ①效果的实际处理函数（破坏选中的卡）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍存在于场上且符合条件的对象卡片全部破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上因效果而被破坏的表侧表示「炎王」卡
function s.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup() and c:IsSetCard(0x81) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
-- ②效果（代替破坏）的发动条件判断与玩家意愿确认
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否使用墓地的这张卡代替破坏
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定哪些卡片被破坏时可以适用此代替效果
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的代替破坏执行函数
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外，作为代替破坏的处理
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

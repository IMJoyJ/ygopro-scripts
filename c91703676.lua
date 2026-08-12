--炎王神天焼
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上的「炎王」怪兽和对方场上的卡各相同数量为对象才能发动。那些卡破坏。
-- ②：自己场上的「炎王」卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册破坏效果和代替破坏效果
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
-- 过滤函数：检查怪兽是否是自己场上表侧表示的「炎王」怪兽，且能被选为效果对象
function s.filter(c,e)
	return c:IsSetCard(0x81) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 效果①的发动判定与对象选择：选择自己场上的「炎王」怪兽和对方场上的卡各相同数量作为对象并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有可成为对象的表侧表示「炎王」怪兽
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)
	-- 获取对方场上所有可成为对象的卡片
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上的炎王怪兽和对方场上的卡中各选择相同数量的卡
	local sg=aux.SelectSameCount(tp,g1,g2)
	-- 将选择的卡片群组设定为当前连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置破坏所选卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- 效果①的效果处理：破坏作为对象的卡片
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果所指向的所有对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将所有符合条件的卡片破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 过滤函数：检查是否是自己场上被效果破坏的表侧表示「炎王」卡，且该破坏不属于代替破坏
function s.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup() and c:IsSetCard(0x81) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 效果②的时代替判定：检查此卡能否除外，自己场上是否存在符合代替破坏条件的炎王卡，并询问玩家是否发动
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 检查受影响的卡是否属于自己场上被效果破坏的「炎王」卡
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 效果②的效果处理：将墓地的这张卡除外作为代替
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡以表侧表示除外作为代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

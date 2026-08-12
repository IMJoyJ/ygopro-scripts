--ゼロ・デイ・ブラスター
-- 效果：
-- ①：把自己场上1只暗属性连接怪兽解放，以那个连接标记数量的场上的卡为对象才能发动。那些卡破坏。
function c93014827.initial_effect(c)
	-- ①：把自己场上1只暗属性连接怪兽解放，以那个连接标记数量的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c93014827.cost)
	e1:SetTarget(c93014827.target)
	e1:SetOperation(c93014827.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数，由于需要在选择解放怪兽的同时确定对象数量，在此处先将Label设为1以作标记
function c93014827.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤不符合破坏条件的卡（不能是解放怪兽的装备卡，且不能是这张陷阱卡自身）
function c93014827.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤可作为解放代价的怪兽（必须是暗属性连接怪兽，且场上存在等同于其连接标记数量的、可作为对象破坏的卡）
function c93014827.costfilter(c,ec,tp)
	local lk=c:GetLink()
	if not c:IsType(TYPE_LINK) or not c:IsAttribute(ATTRIBUTE_DARK) or lk<=0 then return false end
	-- 检查场上是否存在等同于该怪兽连接标记数量的、满足破坏过滤条件的卡作为对象
	return Duel.IsExistingTarget(c93014827.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,lk,c,c,ec)
end
-- 定义效果发动时的对象选择与代价支付函数
function c93014827.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查玩家场上是否存在至少1只满足解放过滤条件的怪兽
			return Duel.CheckReleaseGroup(tp,c93014827.costfilter,1,c,c,tp)
		else return false end
	end
	e:SetLabel(0)
	-- 让玩家选择1只满足解放过滤条件的怪兽
	local sg=Duel.SelectReleaseGroup(tp,c93014827.costfilter,1,1,c,c,tp)
	local lk=sg:GetFirst():GetLink()
	-- 将选择的怪兽解放作为发动代价
	Duel.Release(sg,REASON_COST)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择等同于解放怪兽连接标记数量的场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,lk,lk,c)
	-- 设置当前连锁的操作信息为破坏这些选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理函数
function c93014827.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些对象卡片破坏
	Duel.Destroy(g,REASON_EFFECT)
end

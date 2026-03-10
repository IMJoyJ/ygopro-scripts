--無死虫団の重騎兵
-- 效果：
-- 5星以上的昆虫族怪兽＋昆虫族怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不会被对方的效果破坏。
-- ②：自己·对方回合，自己场上的表侧表示怪兽只有昆虫族怪兽的场合，以包含自己场上的昆虫族怪兽的场上2只怪兽为对象才能发动。那些怪兽除外。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤条件、永续效果和诱发即时效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用满足s.matfilter和昆虫族怪兽各1只作为融合素材
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),true)
	c:EnableReviveLimit()
	-- 创建不会被对方效果破坏的永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果为过滤对方效果破坏的函数
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- 创建②效果的诱发即时效果，可在自己或对方回合发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 定义融合素材过滤函数，筛选5星以上昆虫族怪兽
function s.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsLevelAbove(5)
end
-- 判断是否满足②效果发动条件，即场上只有昆虫族怪兽表侧表示
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在非昆虫族的表侧表示怪兽
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,aux.NOT(Card.IsRace)),tp,LOCATION_MZONE,0,1,nil,RACE_INSECT)
end
-- 定义除外怪兽的过滤函数，需满足为昆虫族、表侧表示且可除外
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAbleToRemove()
		-- 确保所选怪兽中至少有一只可被除外的目标怪兽
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 设置②效果的发动目标选择处理逻辑，选择2只怪兽除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足发动条件，即场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择第一只符合条件的怪兽作为除外对象
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择第二只可被除外的怪兽作为除外对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1)
	g1:Merge(g2)
	-- 设置操作信息，记录将要除外的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
-- 设置②效果的处理函数，执行除外操作
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标怪兽以正面表示形式除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end

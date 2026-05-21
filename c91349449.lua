--ライトレイ ソーサラー
-- 效果：
-- 这张卡不能通常召唤。从游戏中除外的自己的光属性怪兽是3只以上的场合才能特殊召唤。1回合1次，可以选择从游戏中除外的1只自己的光属性怪兽回到卡组，选择场上表侧表示存在的1只怪兽从游戏中除外。这个效果发动的回合，这张卡不能攻击。
function c91349449.initial_effect(c)
	c:EnableReviveLimit()
	-- 从游戏中除外的自己的光属性怪兽是3只以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c91349449.spcon)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择从游戏中除外的1只自己的光属性怪兽回到卡组，选择场上表侧表示存在的1只怪兽从游戏中除外。这个效果发动的回合，这张卡不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91349449,0))  --"除外"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c91349449.rmcost)
	e3:SetTarget(c91349449.rmtg)
	e3:SetOperation(c91349449.rmop)
	c:RegisterEffect(e3)
end
-- 过滤除外区表侧表示的光属性怪兽
function c91349449.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤规则的条件判定：怪兽区域有空位，且自己被除外的光属性怪兽在3只以上
function c91349449.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在至少3只表侧表示的光属性怪兽
		and Duel.IsExistingMatchingCard(c91349449.spfilter,tp,LOCATION_REMOVED,0,3,nil)
end
-- 效果发动代价：检查本回合是否未进行攻击宣言，并给自身添加本回合不能攻击的限制
function c91349449.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 1回合1次，可以选择从游戏中除外的1只自己的光属性怪兽回到卡组，选择场上表侧表示存在的1只怪兽从游戏中除外。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 过滤自己除外区表侧表示、且能回到卡组的光属性怪兽
function c91349449.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 过滤场上表侧表示、且能被除外的怪兽
function c91349449.filter2(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果的目标选择：检查并选择1只除外的光属性怪兽和1只场上的表侧表示怪兽作为对象
function c91349449.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己除外区是否存在至少1只可以回到卡组的表侧表示光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c91349449.filter1,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查场上是否存在至少1只可以除外的表侧表示怪兽
		and Duel.IsExistingTarget(c91349449.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己除外区1只表侧表示的光属性怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c91349449.filter1,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c91349449.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
-- 效果处理：将作为对象的除外怪兽送回卡组，若成功，则将作为对象的场上怪兽除外
function c91349449.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	-- 检查第一个对象是否仍适用于该效果，并将其送回卡组洗切
	if tc1:IsRelateToEffect(e) and Duel.SendtoDeck(tc1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		if tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
			-- 将第二个对象以表侧表示除外
			Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)
		end
	end
end

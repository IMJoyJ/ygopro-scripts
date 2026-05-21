--カオス・ソーサラー
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽各1只除外的场合可以特殊召唤。
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只表侧表示怪兽除外。
function c9596126.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9596126,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c9596126.spcon)
	e1:SetTarget(c9596126.sptg)
	e1:SetOperation(c9596126.spop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只表侧表示怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9596126,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c9596126.rmcost)
	e2:SetTarget(c9596126.rmtg)
	e2:SetOperation(c9596126.rmop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可作为特殊召唤Cost除外的光·暗属性怪兽
function c9596126.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 特殊召唤规则的条件判定：检查怪兽区域是否有空位，以及墓地是否存在光·暗属性怪兽各1只
function c9596126.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中满足特殊召唤Cost条件的所有光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c9596126.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查墓地中是否存在光属性和暗属性怪兽各1只的组合
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 特殊召唤规则的准备阶段：从墓地中选择光·暗属性怪兽各1只，并将其保存在效果标签中
function c9596126.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中满足特殊召唤Cost条件的所有光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c9596126.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从墓地中选择光属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行阶段：将选定的光·暗属性怪兽除外，并进行特殊召唤
function c9596126.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选定的光·暗属性怪兽以表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 效果发动的Cost：检查本回合是否未宣言攻击，并给自身添加本回合不能攻击的限制
function c9596126.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只表侧表示怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 过滤场上表侧表示且可以被除外的怪兽
function c9596126.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果的发动准备：选择场上1只表侧表示怪兽作为对象，并设置除外操作信息
function c9596126.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c9596126.tgfilter(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c9596126.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9596126.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果会除外选中的对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果的执行：将作为对象的怪兽除外
function c9596126.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

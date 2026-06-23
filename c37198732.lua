--レベル・マイスター
-- 效果：
-- 把手卡1只怪兽送去墓地，选择自己场上表侧表示存在的最多2只怪兽才能发动。选择的怪兽的等级直到结束阶段时变成和为这张卡发动而送去墓地的怪兽的原本等级相同。
function c37198732.initial_effect(c)
	-- 创建效果，设置为发动时点，自由连锁，需要选择对象，设置发动代价、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c37198732.cost)
	e1:SetTarget(c37198732.target)
	e1:SetOperation(c37198732.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查手牌中是否存在等级大于0且能作为代价送去墓地的怪兽
function c37198732.cfilter(c)
	return c:GetLevel()>0 and c:IsAbleToGraveAsCost()
end
-- 发动代价函数，检查手牌是否存在满足条件的怪兽，若有则提示选择并将其送去墓地
function c37198732.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查手牌中是否存在至少1张满足条件的怪兽
		if Duel.IsExistingMatchingCard(c37198732.cfilter,tp,LOCATION_HAND,0,1,nil) then
			e:SetLabel(1)
			return true
		else
			return false
		end
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手牌中满足条件的怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c37198732.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	g:GetFirst():CreateEffectRelation(e)
end
-- 过滤函数，用于检查场上表侧表示且等级大于0的怪兽
function c37198732.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果目标函数，检查场上是否存在满足条件的怪兽，若有则提示选择1~2只
function c37198732.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37198732.filter(chkc) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在至少1只满足条件的怪兽
		return Duel.IsExistingTarget(c37198732.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1~2只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c37198732.filter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- 效果处理函数，获取被送去墓地的怪兽等级，并为选择的怪兽设置等级变更效果
function c37198732.activate(e,tp,eg,ep,ev,re,r,rp)
	local lc=e:GetLabelObject()
	if not lc:IsRelateToEffect(e) then return end
	local lv=lc:GetLevel()
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 为选择的怪兽设置等级变更效果，使其等级变为被送去墓地的怪兽的原本等级，并在结束阶段重置
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end

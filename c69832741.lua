--霊魂消滅
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 墓地的怪兽从游戏中除外的场合，用自己场上的怪兽从游戏中除外代替。这个效果发动的回合有效。
function c69832741.initial_effect(c)
	-- 这个效果发动的回合有效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c69832741.activate)
	c:RegisterEffect(e1)
end
-- 魔法卡发动时的效果处理：注册一个在回合结束前适用的、用自己场上怪兽代替墓地怪兽除外的效果
function c69832741.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 墓地的怪兽从游戏中除外的场合，用自己场上的怪兽从游戏中除外代替。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(c69832741.reptg)
	e1:SetValue(c69832741.repval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该代替除外的效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤满足“在墓地且即将被除外的怪兽”条件的卡片
function c69832741.repfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:GetDestination()==LOCATION_REMOVED and c:IsType(TYPE_MONSTER)
end
-- 代替除外效果的条件判断与代替处理
function c69832741.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c69832741.repfilter,nil)
		-- 检查自己场上是否存在足够数量可除外的怪兽以进行代替
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,count,nil)
	end
	local count=eg:FilterCount(c69832741.repfilter,nil)
	-- 给玩家发送提示信息，要求选择用于代替除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(69832741,0))  --"请选择要代替除外的怪兽"
	-- 选择自己场上与被除外墓地怪兽数量相同的怪兽
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,count,count,nil)
	-- 将选中的自己场上的代替怪兽除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	return true
end
-- 指定该代替效果仅适用于满足过滤条件的卡片
function c69832741.repval(e,c)
	return c69832741.repfilter(c)
end

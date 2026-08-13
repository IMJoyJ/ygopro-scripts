--ルドラの魔導書
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「冰火之魔导书」以外的自己的手卡·场上（表侧表示）1张「魔导书」卡或者自己场上1只表侧表示的魔法师族怪兽送去墓地，自己抽2张。
function c23314220.initial_effect(c)
	-- 对应效果原文：这个卡名的卡在1回合只能发动1张。①：「冰火之魔导书」以外的自己的手卡·场上（表侧表示）1张「魔导书」卡或者自己场上1只表侧表示的魔法师族怪兽送去墓地，自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23314220+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23314220.target)
	e1:SetOperation(c23314220.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为发动代价的卡：自己手卡中的「魔导书」卡、自己场上表侧表示的「魔导书」卡，或自己场上表侧表示的魔法师族怪兽；且不能是「冰火之魔导书」本身，并能被效果送去墓地。
function c23314220.filter(c)
	return (((c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0x106e))
		or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER)))
		and not c:IsCode(23314220) and c:IsAbleToGrave()
end
-- 效果发动的合法性判断：确认自己可以抽2张卡，且手卡·场上有满足条件的卡可以作为发动代价。
function c23314220.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动时点进行合法性检查，先确认自己玩家未被禁止抽卡，可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 同时确认自己手卡·场上存在至少1张满足代价筛选条件的卡（排除「冰火之魔导书」自身）。
		and Duel.IsExistingMatchingCard(c23314220.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置本次连锁的操作信息：效果处理时将把1张自己手卡或场上的卡送去墓地（对象在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	-- 设置本次连锁的操作信息：效果处理时自己将抽2张卡（处理时确定，因此对象设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理部分：选择并送去1张满足条件的卡作为代价，若该卡确实被效果送去墓地，则自己抽2张。
function c23314220.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡·场上选择1张满足代价筛选条件的卡（排除「冰火之魔导书」自身）。
	local g=Duel.SelectMatchingCard(tp,c23314220.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	-- 判定选择到的卡是否确实被效果成功送去墓地，且该卡仍存在于墓地中，只有满足条件才继续抽卡。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 让该效果的控制者自己抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

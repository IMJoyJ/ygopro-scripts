--ガガガカイザー
-- 效果：
-- 这张卡在自己场上有这张卡以外的名字带有「我我我」的怪兽存在的场合才能攻击。此外，1回合1次，把自己墓地1只怪兽从游戏中除外才能发动。自己场上的全部名字带有「我我我」的怪兽的等级变成和为这个效果发动而从游戏中除外的怪兽相同等级。这张卡不能作为同调素材。
function c9583383.initial_effect(c)
	-- 这张卡在自己场上有这张卡以外的名字带有「我我我」的怪兽存在的场合才能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c9583383.atkcon)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 1回合1次，把自己墓地1只怪兽从游戏中除外才能发动。自己场上的全部名字带有「我我我」的怪兽的等级变成和为这个效果发动而从游戏中除外的怪兽相同等级。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9583383,0))  --"等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c9583383.lvcost)
	e3:SetOperation(c9583383.lvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的名字带有「我我我」的怪兽
function c9583383.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
-- 攻击条件：检查自己场上是否存在除自身以外的名字带有「我我我」的怪兽
function c9583383.atkcon(e)
	-- 如果自己场上不存在除自身以外的名字带有「我我我」的怪兽，则不能攻击
	return not Duel.IsExistingMatchingCard(c9583383.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件（除外代价）：自己墓地中等级大于0、可以除外，且能使场上至少1只「我我我」怪兽等级发生改变的怪兽
function c9583383.rfilter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsAbleToRemoveAsCost()
		-- 且自己场上存在至少1只等级与该墓地怪兽不同、可以改变等级的名字带有「我我我」的怪兽
		and Duel.IsExistingMatchingCard(c9583383.tfilter,tp,LOCATION_MZONE,0,1,nil,lv)
end
-- 过滤条件（等级改变对象）：场上表侧表示、等级不等于目标等级且大于等于1的名字带有「我我我」的怪兽
function c9583383.tfilter(c,clv)
	return not c:IsLevel(clv) and c:IsLevelAbove(1) and c:IsFaceup() and c:IsSetCard(0x54)
end
-- 等级变化效果的发动代价：选择自己墓地1只怪兽除外，并记录其等级
function c9583383.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己墓地是否存在满足除外代价条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9583383.rfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足代价条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c9583383.rfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	-- 将选中的墓地怪兽的等级保存为效果参数，以便在效果处理时读取
	Duel.SetTargetParam(lv)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 等级变化效果的处理：将自己场上全部名字带有「我我我」的怪兽的等级变成与被除外怪兽相同的等级
function c9583383.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的名字带有「我我我」的怪兽
	local g=Duel.GetMatchingGroup(c9583383.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取在发动阶段保存的被除外怪兽的等级
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部名字带有「我我我」的怪兽的等级变成和为这个效果发动而从游戏中除外的怪兽相同等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
